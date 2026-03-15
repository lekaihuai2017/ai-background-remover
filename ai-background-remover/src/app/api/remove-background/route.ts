import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    // 解析请求体
    const formData = await request.formData();
    const image = formData.get('image');
    
    if (!image) {
      return NextResponse.json({
        error: 'No image provided'
      }, { status: 400 });
    }
    
    // 这里应该集成实际的AI背景移除服务
    // 示例：使用Cloudflare AI或第三方API
    const result = await processImageWithAI(image);
    
    return NextResponse.json({
      success: true,
      result: result,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Error processing image:', error);
    
    return NextResponse.json({
      error: 'Failed to process image',
      message: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

// Remove.bg API 图像处理函数
async function processImageWithAI(image: File | string) {
  const apiKey = process.env.REMOVE_BG_API_KEY;
  const apiUrl = process.env.REMOVE_BG_API_URL || 'https://api.remove.bg/v1.0/removebg';
  
  if (!apiKey) {
    throw new Error('Remove.bg API key is not configured');
  }
  
  try {
    const startTime = Date.now();
    
    // 准备表单数据
    const formData = new FormData();
    
    if (image instanceof File) {
      // 如果是File对象，直接添加到表单
      formData.append('image_file', image);
    } else {
      // 如果是base64字符串，转换为Blob
      const base64Data = image.replace(/^data:image\/[a-z]+;base64,/, '');
      const buffer = Buffer.from(base64Data, 'base64');
      const blob = new Blob([buffer], { type: 'image/png' });
      formData.append('image_file', blob, 'image.png');
    }
    
    // 添加其他参数
    formData.append('size', 'auto');
    formData.append('format', 'png');
    formData.append('type', 'person');
    formData.append('crop', 'false');
    formData.append('semitransparency', 'true');
    
    // 调用 Remove.bg API
    console.log('API Key:', apiKey.substring(0, 10) + '...');
    console.log('API URL:', apiUrl);
    console.log('FormData prepared');
    
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'X-Api-Key': apiKey,
      },
      body: formData,
    });
    
    console.log('Response status:', response.status);
    console.log('Response headers:', response.headers);
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error('API Error response:', errorText);
      throw new Error(`Remove.bg API error (${response.status}): ${errorText}`);
    }
    
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Remove.bg API error (${response.status}): ${errorText}`);
    }
    
    const processingTime = (Date.now() - startTime) / 1000;
    
    // 获取处理后的图像数据
    const imageBuffer = await response.arrayBuffer();
    const base64Image = Buffer.from(imageBuffer).toString('base64');
    const processedImageUrl = `data:image/png;base64,${base64Image}`;
    
    // 对于PNG格式，我们无法直接获取mask，但可以创建一个简单的mask
    const maskUrl = createSimpleMask(processedImageUrl);
    
    return {
      processedImageUrl,
      maskUrl,
      confidence: 0.98, // Remove.bg 通常有很高的置信度
      processingTime,
      api: 'remove.bg',
      creditsUsed: 1, // Remove.bg 通常每张图片消耗1个积分
    };
    
  } catch (error) {
    console.error('Remove.bg API error:', error);
    throw error;
  }
}

// 创建简单的mask（用于演示）
function createSimpleMask(imageUrl: string): string {
  // 这里应该根据实际需求创建mask
  // 对于演示目的，返回一个简单的透明mask
  return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
}