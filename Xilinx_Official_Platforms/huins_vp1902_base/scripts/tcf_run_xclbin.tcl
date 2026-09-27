if {$argc != 4} {
  puts stderr "Usage: xsdb tcf_run_xclbin.tcl <host> <port> <local-program> <local-xclbin>"
  exit 2
}

set host [lindex $argv 0]
set port [lindex $argv 1]
set local_program [file normalize [lindex $argv 2]]
set local_xclbin [file normalize [lindex $argv 3]]

foreach path [list $local_program $local_xclbin] {
  if {![file isfile $path] || [file size $path] == 0} {
    puts stderr "Missing or empty local artifact: $path"
    exit 2
  }
}

proc upload_file {local_path remote_path permissions} {
  set source [open $local_path rb]
  fconfigure $source -translation binary -encoding binary
  catch {tfile remove $remote_path}
  set target [tfile open $remote_path 0x1a [list Permissions $permissions]]
  while {![eof $source]} {
    set payload [read $source 1048576]
    if {[string length $payload] != 0} {
      tfile write $target $payload
    }
  }
  close $source
  tfile close $target
}

set prefix "/tmp/huins-tcf-xclbin-[pid]"
set remote_program "${prefix}.program"
set remote_xclbin "${prefix}.xclbin"
set remote_script "${prefix}.sh"
set remote_stdout "${prefix}.stdout"
set remote_stderr "${prefix}.stderr"
set remote_rc "${prefix}.rc"
set remote_paths [list \
  $remote_program $remote_xclbin $remote_script \
  $remote_stdout $remote_stderr $remote_rc]

connect -host $host -port $port

foreach path $remote_paths {
  catch {tfile remove $path}
}

puts "UPLOAD_PROGRAM $local_program [file size $local_program]"
upload_file $local_program $remote_program 493
puts "UPLOAD_XCLBIN $local_xclbin [file size $local_xclbin]"
upload_file $local_xclbin $remote_xclbin 420

set script [format {#!/bin/sh
exec >%s 2>%s
printf '%s\n' BOARD_SHA256
sha256sum %s %s
%s %s
rc=$?
printf '%s\n' "$rc" >%s
} $remote_stdout $remote_stderr {%s} \
  $remote_program $remote_xclbin $remote_program $remote_xclbin {%s} $remote_rc]

set handle [tfile open $remote_script 0x1a {Permissions 493}]
tfile write $handle $script
tfile close $handle

puts "START_RESULT [::xsdb::process start -dir /tmp /bin/sh $remote_script]"

set completed 0
for {set attempt 0} {$attempt < 300} {incr attempt} {
  after 1000
  if {![catch {tfile stat $remote_rc}]} {
    set completed 1
    break
  }
}

if {!$completed} {
  puts stderr "Timed out after 300 seconds waiting for $remote_rc"
  disconnect
  exit 124
}

set outputs {}
foreach {label path} [list \
    STDOUT $remote_stdout STDERR $remote_stderr EXIT_CODE $remote_rc] {
  set handle [tfile open $path]
  set payload [tfile read $handle 10485760]
  tfile close $handle
  dict set outputs $label $payload
  puts "$label\n$payload"
}

set result [string trim [dict get $outputs EXIT_CODE]]
foreach path $remote_paths {
  catch {tfile remove $path}
}
disconnect

if {![string is integer -strict $result]} {
  puts stderr "Invalid remote exit code: $result"
  exit 125
}
exit $result
