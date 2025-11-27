// src/components/ThemeToggle.jsx
import React, { useEffect, useState, useRef } from 'react';
import { Button } from '@/components/ui/button';
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";
import { Sun, Moon } from 'lucide-react';

const ThemeToggle = () => {
  const [theme, setTheme] = useState('dark');
  const buttonRef = useRef(null);

  // Initialize theme from localStorage or default to dark
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme') || 'dark';
    setTheme(savedTheme);

    // Apply theme to document
    if (savedTheme === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, []);

  const toggleTheme = (e) => {
    const newTheme = theme === 'dark' ? 'light' : 'dark';

    // Check if View Transitions API is supported
    if (!document.startViewTransition) {
      // Fallback for browsers without View Transitions API
      setTheme(newTheme);
      localStorage.setItem('theme', newTheme);
      if (newTheme === 'dark') {
        document.documentElement.classList.add('dark');
      } else {
        document.documentElement.classList.remove('dark');
      }
      return;
    }

    // Get button position for animation origin
    const button = buttonRef.current;
    if (!button) return;

    const rect = button.getBoundingClientRect();
    const x = rect.left + rect.width / 2;
    const y = rect.top + rect.height / 2;

    // Calculate the diagonal distance to cover entire viewport
    const endRadius = Math.hypot(
      Math.max(x, window.innerWidth - x),
      Math.max(y, window.innerHeight - y)
    );

    // Set CSS variables for animation
    document.documentElement.style.setProperty('--x', `${x}px`);
    document.documentElement.style.setProperty('--y', `${y}px`);
    document.documentElement.style.setProperty('--r', `${endRadius}px`);

    // Start view transition
    const transition = document.startViewTransition(() => {
      setTheme(newTheme);
      localStorage.setItem('theme', newTheme);

      if (newTheme === 'dark') {
        document.documentElement.classList.add('dark');
      } else {
        document.documentElement.classList.remove('dark');
      }
    });
  };

  return (
    <Tooltip>
      <TooltipTrigger asChild>
        <Button
          ref={buttonRef}
          onClick={toggleTheme}
          variant="ghost"
          size="icon"
          className="h-9 w-9 transition-all duration-300 hover:scale-110 relative overflow-visible group"
          aria-label="Toggle theme"
        >
          <div className="relative">
            {theme === 'dark' ? (
              <Sun className="h-4 w-4 text-yellow-500 transition-all duration-300 animate-in fade-in" />
            ) : (
              <Moon className="h-4 w-4 text-primary transition-all duration-300 animate-in fade-in" />
            )}
          </div>
          {/* Subtle glow effect on hover */}
          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-primary/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 -translate-x-full group-hover:translate-x-full" style={{ transition: 'transform 0.6s ease-in-out, opacity 0.3s ease-in-out' }} />
        </Button>
      </TooltipTrigger>
      <TooltipContent>
        <p>Switch to {theme === 'dark' ? 'light' : 'dark'} mode</p>
      </TooltipContent>
    </Tooltip>
  );
};

export default ThemeToggle;
