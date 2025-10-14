// Fallback script for CanvasKit loading issues
(function() {
  console.log('CanvasKit fallback script loaded');
  
  // Check if CanvasKit is available
  if (typeof window.flutterCanvasKit === 'undefined') {
    console.warn('CanvasKit not available, using HTML renderer fallback');
    
    // Set a flag for Flutter to use HTML renderer
    window.flutterCanvasKitFallback = true;
    
    // Try to load CanvasKit from alternative source with better error handling
    const script = document.createElement('script');
    script.src = 'https://unpkg.com/canvaskit-wasm@0.33.0/bin/canvaskit.js';
    script.crossOrigin = 'anonymous';
    script.onload = function() {
      console.log('CanvasKit loaded successfully from fallback source');
    };
    script.onerror = function() {
      console.warn('Alternative CanvasKit source also failed, using HTML renderer');
      // Ensure fallback flag is set
      window.flutterCanvasKitFallback = true;
    };
    document.head.appendChild(script);
  } else {
    console.log('CanvasKit is already available');
  }
})();
