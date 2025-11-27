// src/components/ResizeHandle.jsx
import React, { useState, useCallback, useEffect, useRef } from 'react';

const ResizeHandle = ({
  onResize,           // (delta: number) => void
  side = 'right',     // 'left' | 'right'
  minWidth,
  maxWidth,
  currentWidth,
  className = ''
}) => {
  const [isDragging, setIsDragging] = useState(false);
  const [startX, setStartX] = useState(0);
  const rafRef = useRef(null);

  const handleMouseDown = useCallback((e) => {
    e.preventDefault();
    setIsDragging(true);
    setStartX(e.clientX);
    document.body.style.cursor = 'col-resize';
    document.body.style.userSelect = 'none';
    document.body.classList.add('is-resizing');
  }, []);

  const handleMouseMove = useCallback((e) => {
    if (!isDragging) return;

    // Cancel any pending animation frame
    if (rafRef.current) {
      cancelAnimationFrame(rafRef.current);
    }

    // Use requestAnimationFrame for smooth 60fps updates
    rafRef.current = requestAnimationFrame(() => {
      const delta = side === 'right'
        ? startX - e.clientX  // Terminal: drag left = grow
        : e.clientX - startX; // Sidebar: drag right = grow

      onResize(delta);
      setStartX(e.clientX);
      rafRef.current = null;
    });
  }, [isDragging, startX, side, onResize]);

  const handleMouseUp = useCallback(() => {
    setIsDragging(false);
    document.body.style.cursor = '';
    document.body.style.userSelect = '';
    document.body.classList.remove('is-resizing');

    if (rafRef.current) {
      cancelAnimationFrame(rafRef.current);
      rafRef.current = null;
    }
  }, []);

  const handleDoubleClick = useCallback(() => {
    // Reset to default width
    const defaultWidth = side === 'left' ? 320 : 500;
    const delta = defaultWidth - currentWidth;
    onResize(delta);
  }, [side, currentWidth, onResize]);

  const handleKeyDown = useCallback((e) => {
    const step = e.shiftKey ? 20 : 5;
    if (e.key === 'ArrowLeft') {
      e.preventDefault();
      onResize(side === 'left' ? -step : step);
    } else if (e.key === 'ArrowRight') {
      e.preventDefault();
      onResize(side === 'left' ? step : -step);
    } else if (e.key === 'Home') {
      e.preventDefault();
      onResize(minWidth - currentWidth);
    } else if (e.key === 'End') {
      e.preventDefault();
      onResize(maxWidth - currentWidth);
    }
  }, [side, onResize, minWidth, maxWidth, currentWidth]);

  useEffect(() => {
    if (isDragging) {
      window.addEventListener('mousemove', handleMouseMove);
      window.addEventListener('mouseup', handleMouseUp);

      return () => {
        window.removeEventListener('mousemove', handleMouseMove);
        window.removeEventListener('mouseup', handleMouseUp);
      };
    }
  }, [isDragging, handleMouseMove, handleMouseUp]);

  return (
    <div
      className={`resize-handle ${isDragging ? 'dragging' : ''} ${className}`}
      onMouseDown={handleMouseDown}
      onDoubleClick={handleDoubleClick}
      onKeyDown={handleKeyDown}
      tabIndex={0}
      role="separator"
      aria-orientation="vertical"
      aria-valuenow={currentWidth}
      aria-valuemin={minWidth}
      aria-valuemax={maxWidth}
      aria-label={`Resize ${side} panel (${currentWidth}px)`}
      title="Drag to resize • Double-click to reset • Arrow keys for fine adjustment"
    />
  );
};

export default ResizeHandle;
