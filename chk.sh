#!/bin/sh

raw2cbor(){
  cat /dev/stdin |
    node ./b2cbor.mjs
}

raw2cbor2dbg(){
  cat /dev/stdin |
    raw2cbor |
    fq -d cbor
}

echo helo
printf helo | raw2cbor2dbg
echo

echo he
printf he | raw2cbor2dbg
echo

echo h
printf h | raw2cbor2dbg
echo

echo '(empty bytes)'
printf '' | raw2cbor2dbg
echo

echo longer msg
printf '0123456789abcdefghijklmnopqrstuvwxyz' | raw2cbor2dbg
echo

echo half msg
dd \
  if=/dev/zero \
  of=/dev/stdout \
  bs=32767 \
  count=1 \
  status=none |
  raw2cbor2dbg
echo

echo max msg
dd \
  if=/dev/zero \
  of=/dev/stdout \
  bs=65535 \
  count=1 \
  status=none |
  raw2cbor2dbg
echo

