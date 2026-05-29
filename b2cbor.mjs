//@ts-expect-error
import { readFile } from "node:fs/promises";

(async () => {

  /** @type {string} */
  const wasm = "./b2cbor.wasm";

  const pbytes = readFile(wasm);
  const pwasm = pbytes.then(WebAssembly.instantiate);

  const { instance } = await pwasm;
  const { exports } = instance;
  const { raw2cbor, memory } = exports;

  const buf = await readFile("/dev/stdin");
  const bsz = buf.length;
  const view = new Uint8Array(memory.buffer, 0, bsz);
  view.set(buf);

  const optr = 65536 * 2;

  const rslt = raw2cbor(bsz, optr);

  if(rslt < 0) return;

  const oview = new Uint8Array(
    memory.buffer,
    optr,
    rslt,
  );

  process.stdout.write(oview);

})();
