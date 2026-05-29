(module

  (memory (export "memory") 4)
  ;; 1st page(0x0000_0000 - 0x0000_ffff): the input raw bytes
  ;; 2nd page(0x0001_0000 - 0x0001_ffff): (reserved)
  ;; 3rd page(0x0002_0000 - 0x0002_ffff): the output bytes part 1
  ;; 4th page(0x0003_0000 - 0x0003_ffff): the output bytes part 2

  (func $in2out
    (param $size i32) ;; the size of the input; e.g., 23
    (param $optr i32) ;; the output pointer

    (local $iptr i32)

    (local $eptr i32) ;; ptr to the end of the input; e.g., 0x0000_0023

    local.get $optr
    i32.const 0
    local.get $size
    memory.copy
    return
  )

  (func $raw2cbor (export "raw2cbor")
    (param $size i32) ;; size of the input bytes
    (param $optr i32) ;; ptr to the output(131072)
    (result i32)      ;; size of the output bytes; -1 for invalid input

    ;; reject negative size
    local.get $size
    i32.const 0
    i32.lt_s
    if
      i32.const -1
      return
    end

    ;; reject big one(>65535)
    i32.const 65536
    local.get $size
    i32.le_u
    if
      i32.const -1
      return
    end

    ;; xs: 0~23 bytes
    local.get $size
    i32.const 24
    i32.lt_u
    if
      ;; write the prefix
      local.get $optr
      i32.const 0x0000_0040
      local.get $size
      i32.or
      i32.store8

      ;; copy bytes
      ;; arg 1: size
      local.get $size
      ;; arg 2: output ptr
      local.get $optr
      i32.const 1
      i32.add
      call $in2out

      ;; return the output size
      local.get $size
      i32.const 1
      i32.add
      return
    end

    ;; sm: 24~255 bytes
    local.get $size
    i32.const 256
    i32.lt_u
    if
      ;; write the prefix
      local.get $optr
      i32.const 0x0000_0058
      local.get $size
      i32.const 8
      i32.shl
      i32.or
      i32.store16

      ;; copy bytes
      ;; arg 1: size
      local.get $size
      ;; arg 2: output ptr
      local.get $optr
      i32.const 2
      i32.add
      call $in2out

      ;; return the output size
      local.get $size
      i32.const 2
      i32.add
      return
    end

    ;; sm: 256~65535 bytes
    ;; write the prefix
    local.get $optr
    i32.const 0x0000_0059
    i32.store8 offset=0
    ;; save the size in BE
    local.get $optr
    local.get $size
    i32.const 8
    i32.shr_u
    i32.store8 offset=1
    local.get $optr
    local.get $size
    i32.const 0x0000_00ff
    i32.and
    i32.store8 offset=2

    ;; copy bytes
    ;; arg 1: size
    local.get $size
    ;; arg 2: output ptr
    local.get $optr
    i32.const 3
    i32.add
    call $in2out

    ;; return the output size
    local.get $size
    i32.const 3
    i32.add
  )

)
