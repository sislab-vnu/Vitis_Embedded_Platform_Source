# Run an Xclbin through a TCF Tunnel

This guide runs a Linux host program and its linked xclbin on the Huins VP1902
without SSH credentials for the board. It uses the root-owned Target
Communication Framework (TCF) agent supplied by the AMD EDF image.

The connection path is:

```text
development host -> SSH local forward -> lab gateway -> board TCP port 1534
```

TCF provides root-level file and process access without its own authentication.
Bind the forwarded port to `127.0.0.1`, use only a trusted SSH gateway, and
close the tunnel after the test. Never expose board port 1534 publicly.

## Preconditions

- The board has booted Linux with the linked PDI and matching device tree.
- The board Ethernet address is reachable from the lab gateway. The platform's
  deterministic address is `192.168.1.57` unless local deployment
  configuration changed it.
- The TCF agent is running on board TCP port 1534.
- Vitis 2025.2 is installed on the development host. Its `xsdb` command supplies
  the TCF client commands used below.
- The host program is an AArch64 executable and expects the xclbin path as its
  first argument, as `simple_vadd` does.
- The program and xclbin match the active `BOOT.BIN`, platform device tree, and
  XRT stack. A mismatched linked PDI/xclbin pair can cause an A72 SError.

Set the connection and artifact variables on the development host:

```bash
source <Vitis_install>/Vitis/2025.2/settings64.sh

cd Xilinx_Official_Platforms/huins_vp1902_base
export PLATFORM_ROOT="$PWD"

export LAB_HOST=<lab-gateway-hostname-or-address>
export LAB_USER=<lab-gateway-user>
export LAB_SSH_PORT=<lab-gateway-ssh-port>
export LAB_SSH_KEY=<path-to-private-key>
export BOARD_IP=192.168.1.57
export TCF_LOCAL_PORT=15340
export TCF_CONTROL="/tmp/huins-tcf-${USER}.sock"

export TEST_PROGRAM=<absolute-path-to-aarch64-test-program>
export TEST_XCLBIN=<absolute-path-to-linked-xclbin>

test -x "$TEST_PROGRAM"
test -s "$TEST_XCLBIN"
file "$TEST_PROGRAM"
sha256sum "$TEST_PROGRAM" "$TEST_XCLBIN"
```

Require `file` to identify the program as an AArch64 ELF executable. Record the
local hashes with the test result.

## Verify the Gateway Path

Test from the gateway, not only from the development host:

```bash
ssh -i "$LAB_SSH_KEY" -p "$LAB_SSH_PORT" \
  -o BatchMode=yes -o ConnectTimeout=10 \
  "$LAB_USER@$LAB_HOST" \
  "ping -c 3 '$BOARD_IP' && timeout 5 bash -c '</dev/tcp/$BOARD_IP/1534'"
```

Do not continue unless both checks succeed. A local listening tunnel does not
prove that the gateway can reach the board. If the gateway reports `Destination
Host Unreachable` or `No route to host`, fix board networking first.

## Open the Tunnel

Create a managed, loopback-only SSH tunnel:

```bash
if [ -S "$TCF_CONTROL" ]; then
  if ssh -S "$TCF_CONTROL" -p "$LAB_SSH_PORT" -O check \
      "$LAB_USER@$LAB_HOST"; then
    printf '%s\n' "A managed tunnel is already active: $TCF_CONTROL" >&2
    exit 1
  fi
  rm -f "$TCF_CONTROL"
fi

ssh -M -S "$TCF_CONTROL" -f -N \
  -i "$LAB_SSH_KEY" -p "$LAB_SSH_PORT" \
  -o BatchMode=yes \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=15 \
  -o ServerAliveCountMax=3 \
  -L "127.0.0.1:${TCF_LOCAL_PORT}:${BOARD_IP}:1534" \
  "$LAB_USER@$LAB_HOST"

ssh -S "$TCF_CONTROL" -p "$LAB_SSH_PORT" -O check \
  "$LAB_USER@$LAB_HOST"
```

If SSH reports that the local port is already in use, inspect the existing
listener instead of killing an unrelated process:

```bash
ss -ltnp "sport = :$TCF_LOCAL_PORT"
```

## Upload and Run

The checked-in helper uploads the program and xclbin to temporary files on the
board, computes their board-side SHA-256 hashes, starts the program through TCF
`ProcessesV1`, and captures stdout, stderr, and the actual exit status:

```bash
xsdb scripts/tcf_run_xclbin.tcl \
  127.0.0.1 "$TCF_LOCAL_PORT" \
  "$TEST_PROGRAM" "$TEST_XCLBIN"
```

The helper transfers binary data in 1 MiB chunks and removes its board-side
temporary files after collecting the result. It allows five minutes for the
program to finish. A successful `simple_vadd` run must include all of:

```text
Mismatches: 0/4096
TEST PASSED
EXIT_CODE
0
```

The `BOARD_SHA256` lines must match the hashes recorded before upload. Do not
treat `START_RESULT`, a successful upload, or xclbin loading alone as a passing
test. The application-specific success text and exit code zero are required.

To run artifacts already installed on the board, set `TEST_PROGRAM` and
`TEST_XCLBIN` to local copies of the same files and use the helper above. This
revalidates the transfer and avoids accidentally executing stale files. The
previously validated board paths were `/storage/simple_vadd` and
`/storage/vadd.xclbin`.

## Close the Tunnel

Always close the managed tunnel when testing is complete:

```bash
ssh -S "$TCF_CONTROL" -p "$LAB_SSH_PORT" -O exit \
  "$LAB_USER@$LAB_HOST" || true
rm -f "$TCF_CONTROL"
```

## Failure Diagnosis

| Symptom | Action |
|---|---|
| Gateway cannot ping the board | Check board power, Ethernet, boot completion, and the configured board address |
| Gateway has link but ARP fails | Inspect `ip -4 -br addr show end0` and `networkctl status end0` through UART; TCF cannot repair an unreachable network |
| `xsdb` reports `connection failed` | Re-run the gateway TCP check, then verify the SSH control connection and local forward |
| TCF connects but upload fails | Check free space in `/tmp`, artifact size, and whether concurrent tests exhausted board resources |
| Run times out | Inspect UART/kernel logs; check for an A72 exception, `zocl` failure, or a hung compute unit |
| `xrt-smi` shows no device | Verify `zocl`, `/dev/dri/renderD128`, the linked PDI, and the matching device tree |
| Program exits nonzero | Preserve stdout/stderr and hashes; do not rerun with a different xclbin until the active PDI/DT/artifact set is identified |
| A72 SError occurs during xclbin load | Stop: the active PDI, device tree, and xclbin are probably mismatched; restore one known-good matched set |

For board and lab-host network setup, see
[NETWORK_BRINGUP_GUIDE.md](NETWORK_BRINGUP_GUIDE.md). For board recovery and
JTAG diagnostics, see [JTAG_XSDB_GUIDE.md](JTAG_XSDB_GUIDE.md). For the
validated artifact hashes and known runtime failures, see
[TROUBLESHOOTING.md](TROUBLESHOOTING.md).
