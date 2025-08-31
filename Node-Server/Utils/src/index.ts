export const PORT_NUMBER = 3000;
export const REGISTRY_URL = "http://wcpp-registry:3000";

// Retry logic for registry
export async function registerWithRetry(
  name: string,
  url: string,
  maxRetries = 5
) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const res = await fetch(`${REGISTRY_URL}/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, url }),
      });
      if (!res.ok) throw new Error(`Status ${res.status}`);
      console.log("Registered with registry");
      return;
    } catch (err) {
      console.log(
        `Failed to register (attempt ${i + 1}): ${(err as Error).message}`
      );
      await new Promise((r) => setTimeout(r, 1000 * (i + 1)));
    }
  }
  console.log("Could not register with registry. Exiting.");
  process.exit(1);
}

export async function lookupService(name: string): Promise<string | null> {
  try {
    const res = await fetch(`${REGISTRY_URL}/lookup?name=${name}`);
    if (!res.ok) throw new Error(`Status ${res.status}`);
    const { url } = await res.json();
    return url;
  } catch (err) {
    console.log(`Lookup failed for ${name}: ${(err as Error).message}`);
    return null;
  }
}
