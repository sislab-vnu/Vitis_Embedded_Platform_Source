#!/usr/bin/env python3

import sys

import numpy as np
import pyxrt


COUNT = 4096
SIZE = COUNT * np.dtype(np.int32).itemsize


def main(xclbin_path):
    device = pyxrt.device(0)
    xclbin = pyxrt.xclbin(xclbin_path)
    uuid = device.load_xclbin(xclbin)
    kernel = pyxrt.kernel(device, uuid, "vadd")

    in1_bo = pyxrt.bo(device, SIZE, pyxrt.bo.normal, kernel.group_id(0))
    in2_bo = pyxrt.bo(device, SIZE, pyxrt.bo.normal, kernel.group_id(1))
    out_bo = pyxrt.bo(device, SIZE, pyxrt.bo.normal, kernel.group_id(2))

    in1 = np.frombuffer(in1_bo.map(), dtype=np.int32, count=COUNT)
    in2 = np.frombuffer(in2_bo.map(), dtype=np.int32, count=COUNT)
    output = np.frombuffer(out_bo.map(), dtype=np.int32, count=COUNT)
    expected = np.arange(COUNT, dtype=np.int32) * 2

    in1[:] = np.arange(COUNT, dtype=np.int32)
    in2[:] = np.arange(COUNT, dtype=np.int32)
    output[:] = 0

    to_device = pyxrt.xclBOSyncDirection.XCL_BO_SYNC_BO_TO_DEVICE
    from_device = pyxrt.xclBOSyncDirection.XCL_BO_SYNC_BO_FROM_DEVICE
    in1_bo.sync(to_device, SIZE, 0)
    in2_bo.sync(to_device, SIZE, 0)

    run = kernel(in1_bo, in2_bo, out_bo, COUNT)
    state = run.wait()
    out_bo.sync(from_device, SIZE, 0)

    mismatches = np.flatnonzero(output != expected)
    print(f"pyxrt module: {pyxrt.__file__}")
    print(f"kernel completion state: {state}")
    print(f"mismatches: {mismatches.size}/{COUNT}")
    if mismatches.size:
        for index in mismatches[:16]:
            print(
                f"mismatch[{index}]: got {output[index]}, "
                f"expected {expected[index]}"
            )
        return 1

    print("PYXRT VADD TEST PASSED")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(f"usage: {sys.argv[0]} <vadd.xclbin>")
    raise SystemExit(main(sys.argv[1]))
