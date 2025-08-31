export const PORT_NUMBER = 3000;
export const REGISTRY_URL = "http://wcpp-registry:3000";

// Retry logic

export async function retryFunction<T>(
  asyncFunc: () => Promise<{ status: number; res?: T; message?: string }>,
  maxRetries = 5
): Promise<{ attempts: number; result: T }> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const { status, res, message } = await asyncFunc();
      if (status != 200)
        throw new Error(
          `Status ${status} ${message ? `with reason: ${message}` : ""}`
        );
      return { attempts: i + 1, result: res! };
    } catch (err) {
      console.log(`Received error on attempt: ${(err as Error).message}`);
      await new Promise((r) => setTimeout(r, 1000 * (i + 1)));
    }
  }
  process.exit(1);
}

export async function registerWithRetry(name: string, url: string) {
  const fetchFunc = async () => {
    const res = await fetch(`${REGISTRY_URL}/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, url }),
    });
    return res.ok
      ? { status: 200, res }
      : { status: res.status, message: "Unable to register." };
  };
  const { attempts } = await retryFunction(fetchFunc);
  console.log(
    `Successfully registered in ${attempts} ${attempts > 1 ? "tries" : "try"}.`
  );
}

async function lookupService(name: string): Promise<string | null> {
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

export function get_url_factory(name: string) {
  let url: string | null = null;
  return async () => {
    if (url == null) url = (await lookupService(name)) as string;
    return url;
  };
}

// ****************************************************
// `npm run update` to push changes to other packages.
// ****************************************************
