import fs from "node:fs";

const NODE_UID = 1000;
const NODE_GID = 1000;
const STATE_DIR = process.env.OPENCLAW_STATE_DIR?.trim() || "/data/.openclaw";
const WORKSPACE_DIR = process.env.OPENCLAW_WORKSPACE_DIR?.trim() || "/data/workspace";

if (process.getuid?.() === 0) {
  // Railway overlays /data at runtime, so image-time ownership does not carry
  // through. Create only the required directories and hand them to node.
  for (const dir of ["/data", STATE_DIR, WORKSPACE_DIR]) {
    fs.mkdirSync(dir, { recursive: true, mode: 0o700 });
    fs.chownSync(dir, NODE_UID, NODE_GID);
  }

  process.setgid(NODE_GID);
  process.setuid(NODE_UID);
}

await import("./server.js");
