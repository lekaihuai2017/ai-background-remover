// functions/api/remove-background.js
// Cloudflare Pages Function - 调用 remove.bg API 移除图片背景

export async function onRequestPost(context) {
  const { request, env } = context;

  // CORS headers
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
  };

  try {
    const formData = await request.formData();
    const image = formData.get("image");

    if (!image) {
      return new Response(JSON.stringify({ error: "No image provided" }), {
        status: 400,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    const apiKey = env.REMOVE_BG_API_KEY;
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "REMOVE_BG_API_KEY is not configured" }),
        {
          status: 500,
          headers: { "Content-Type": "application/json", ...corsHeaders },
        }
      );
    }

    const startTime = Date.now();

    // 构建发送给 remove.bg 的 FormData
    const removeBgForm = new FormData();
    removeBgForm.append("image_file", image);
    removeBgForm.append("size", "auto");
    removeBgForm.append("format", "png");
    removeBgForm.append("semitransparency", "true");

    const response = await fetch("https://api.remove.bg/v1.0/removebg", {
      method: "POST",
      headers: { "X-Api-Key": apiKey },
      body: removeBgForm,
    });

    if (!response.ok) {
      const errorText = await response.text();
      return new Response(
        JSON.stringify({
          error: `remove.bg API error (${response.status})`,
          detail: errorText,
        }),
        {
          status: response.status,
          headers: { "Content-Type": "application/json", ...corsHeaders },
        }
      );
    }

    const processingTime = (Date.now() - startTime) / 1000;

    // 将返回的 PNG 转为 base64 data URL
    const imageBuffer = await response.arrayBuffer();
    const base64Image = btoa(
      String.fromCharCode(...new Uint8Array(imageBuffer))
    );
    const processedImageUrl = `data:image/png;base64,${base64Image}`;

    // 读取 remove.bg 返回的积分信息
    const creditsCharged = response.headers.get("X-Credits-Charged");

    return new Response(
      JSON.stringify({
        success: true,
        result: {
          processedImageUrl,
          maskUrl: processedImageUrl, // PNG 本身带透明通道，mask 复用
          confidence: 0.98,
          processingTime,
          api: "remove.bg",
          creditsUsed: creditsCharged ? Number(creditsCharged) : 1,
        },
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { "Content-Type": "application/json", ...corsHeaders },
      }
    );
  } catch (error) {
    console.error("Error processing image:", error);
    return new Response(
      JSON.stringify({ error: "Failed to process image", message: error.message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      }
    );
  }
}

export async function onRequestOptions() {
  return new Response(null, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    },
  });
}
