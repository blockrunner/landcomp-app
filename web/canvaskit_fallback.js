// Fallback script for CanvasKit loading issues
(function() {
  console.log('CanvasKit fallback script loaded');
  
  // Check if CanvasKit is available
  if (typeof window.flutterCanvasKit === 'undefined') {
    console.warn('CanvasKit not available, using HTML renderer fallback');
    
    // Set a flag for Flutter to use HTML renderer
    window.flutterCanvasKitFallback = true;
    
    // Try to load CanvasKit from alternative source
    const script = document.createElement('script');
    script.src = 'https://unpkg.com/canvaskit-wasm@0.33.0/bin/canvaskit.js';
    script.onerror = function() {
      console.warn('Alternative CanvasKit source also failed, using HTML renderer');
    };
    document.head.appendChild(script);
  }
})();
