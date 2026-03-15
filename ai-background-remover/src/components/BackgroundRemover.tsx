'use client';

import { useState, ChangeEvent } from 'react';
import Image from 'next/image';

export default function BackgroundRemover() {
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [processedImage, setProcessedImage] = useState<{
    processedImageUrl: string;
    maskUrl: string;
    confidence: number;
    processingTime: number;
    timestamp: string;
    api?: string;
    creditsUsed?: number;
  } | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleImageSelect = (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const result = e.target?.result as string;
        if (result) {
          setSelectedImage(result);
          setProcessedImage(null);
          setError(null);
        }
      };
      reader.readAsDataURL(file);
    }
  };

  const handleRemoveBackground = async () => {
    if (!selectedImage) {
      setError('请先选择一张图片');
      return;
    }

    setIsProcessing(true);
    setError(null);

    try {
      const formData = new FormData();
      // 将base64数据转换为Blob
      const response = await fetch(selectedImage);
      const blob = await response.blob();
      formData.append('image', blob);

      console.log('Sending request to Remove.bg API...');
      
      const apiResponse = await fetch('/api/remove-background', {
        method: 'POST',
        body: formData,
      });

      console.log('API Response status:', apiResponse.status);
      console.log('API Response headers:', apiResponse.headers);

      if (!apiResponse.ok) {
        const errorText = await apiResponse.text();
        console.error('API Error:', errorText);
        throw new Error(`HTTP ${apiResponse.status}: ${errorText}`);
      }

      const result = await apiResponse.json();
      console.log('API Response JSON:', result);

      if (result.success) {
        setProcessedImage(result.result);
      } else {
        setError(result.error || '处理失败');
      }
    } catch (error) {
      console.error('Error:', error);
      setError(error instanceof Error ? error.message : '网络错误，请重试');
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="text-center mb-8">
        <h1 className="text-3xl font-bold mb-2">AI 背景移除工具</h1>
        <p className="text-gray-600">使用 Remove.bg API 技术，一键智能移除图片背景</p>
      </div>
      
      <div className="grid md:grid-cols-2 gap-8">
        {/* 原始图片上传 */}
        <div className="space-y-4">
          <h2 className="text-xl font-semibold flex items-center">
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            原始图片
          </h2>
          
          <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
            <input
              type="file"
              accept="image/*"
              onChange={handleImageSelect}
              className="hidden"
              id="image-upload"
            />
            <label
              htmlFor="image-upload"
              className="cursor-pointer flex flex-col items-center space-y-2"
            >
              <svg
                className="w-12 h-12 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 48 48"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                />
              </svg>
              <span className="text-sm text-gray-600">
                {selectedImage ? '点击更换图片' : '点击选择图片'}
              </span>
              <p className="text-xs text-gray-500">支持 JPG, PNG, WebP 格式</p>
            </label>
          </div>

          {selectedImage && (
            <div className="mt-4">
              <div className="relative">
                <Image
                  src={selectedImage}
                  alt="Selected"
                  width={400}
                  height={300}
                  className="w-full h-auto rounded-lg shadow-lg"
                />
                <div className="absolute top-2 right-2 bg-blue-600 text-white px-2 py-1 rounded text-xs">
                  原始图片
                </div>
              </div>
              <button
                onClick={handleRemoveBackground}
                disabled={isProcessing}
                className={`w-full mt-4 py-3 px-6 rounded-lg font-medium text-white transition-colors ${
                  isProcessing
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-blue-600 hover:bg-blue-700'
                }`}
              >
                {isProcessing ? (
                  <span className="flex items-center justify-center">
                    <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    正在处理中...
                  </span>
                ) : (
                  <span className="flex items-center justify-center">
                    <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    移除背景
                  </span>
                )}
              </button>
            </div>
          )}
        </div>

        {/* 处理结果 */}
        <div className="space-y-4">
          <h2 className="text-xl font-semibold flex items-center">
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            处理结果
          </h2>
          
          {error && (
            <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
              <strong>错误:</strong> {error}
            </div>
          )}

          {processedImage ? (
            <div className="space-y-4">
              <div className="border rounded-lg p-4">
                <h3 className="font-medium mb-2 flex items-center">
                  <svg className="w-4 h-4 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                  处理完成
                </h3>
                <div className="relative">
                  <Image
                    src={processedImage.processedImageUrl}
                    alt="Processed"
                    width={400}
                    height={300}
                    className="w-full h-auto rounded-lg shadow-lg"
                  />
                  <div className="absolute top-2 right-2 bg-green-600 text-white px-2 py-1 rounded text-xs">
                    透明背景
                  </div>
                </div>
              </div>
              
              <div className="bg-gray-50 p-4 rounded-lg">
                <h3 className="font-medium mb-3 flex items-center">
                  <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  处理信息
                </h3>
                <div className="text-sm space-y-2">
                  <div className="flex justify-between">
                    <span className="text-gray-600">API 服务:</span>
                    <span className="font-medium">{processedImage.api || 'remove.bg'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">置信度:</span>
                    <span className="font-medium text-green-600">{(processedImage.confidence * 100).toFixed(1)}%</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">处理时间:</span>
                    <span className="font-medium">{processedImage.processingTime.toFixed(1)}s</span>
                  </div>
                  {processedImage.creditsUsed && (
                    <div className="flex justify-between">
                      <span className="text-gray-600">消耗积分:</span>
                      <span className="font-medium">{processedImage.creditsUsed}</span>
                    </div>
                  )}
                  <div className="flex justify-between">
                    <span className="text-gray-600">处理时间:</span>
                    <span className="font-medium">{new Date(processedImage.timestamp).toLocaleString()}</span>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-12 text-center">
              <svg
                className="w-16 h-16 text-gray-400 mx-auto mb-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
                />
              </svg>
              <p className="text-gray-500">处理结果将显示在这里</p>
              <p className="text-sm text-gray-400 mt-2">上传图片后点击"移除背景"开始处理</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}