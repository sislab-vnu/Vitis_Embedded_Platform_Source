#include <cstddef>
#include <exception>
#include <iostream>

#include <xrt/xrt_bo.h>
#include <xrt/xrt_device.h>
#include <xrt/xrt_kernel.h>

int main(int argc, char** argv) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <xclbin>\n";
        return 2;
    }

    constexpr std::size_t count = 4096;
    constexpr std::size_t bytes = count * sizeof(unsigned int);

    try {
        auto device = xrt::device(0);
        auto uuid = device.load_xclbin(argv[1]);
        auto kernel = xrt::kernel(device, uuid, "vadd");

        auto input_a = xrt::bo(device, bytes, kernel.group_id(0));
        auto input_b = xrt::bo(device, bytes, kernel.group_id(1));
        auto output = xrt::bo(device, bytes, kernel.group_id(2));

        auto* a = input_a.map<unsigned int*>();
        auto* b = input_b.map<unsigned int*>();
        auto* out = output.map<unsigned int*>();

        for (std::size_t i = 0; i < count; ++i) {
            a[i] = static_cast<unsigned int>(i);
            b[i] = static_cast<unsigned int>(i * 2);
            out[i] = 0;
        }

        input_a.sync(XCL_BO_SYNC_BO_TO_DEVICE);
        input_b.sync(XCL_BO_SYNC_BO_TO_DEVICE);

        auto run = kernel(input_a, input_b, output, count);
        run.wait();
        output.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

        std::size_t mismatches = 0;
        for (std::size_t i = 0; i < count; ++i) {
            if (out[i] != a[i] + b[i])
                ++mismatches;
        }

        std::cout << "Mismatches: " << mismatches << '/' << count << '\n';
        if (mismatches != 0) {
            std::cerr << "TEST FAILED\n";
            return 1;
        }

        std::cout << "TEST PASSED\n";
        return 0;
    } catch (const std::exception& error) {
        std::cerr << "TEST FAILED: " << error.what() << '\n';
        return 1;
    }
}
