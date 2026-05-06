"""
fix_logo.py — NyumbaLink logo padding fix
─────────────────────────────────────────
Run from your project root:
    python fix_logo.py

What it does:
  • Takes assets/images/logo.png
  • Places it centred on a 1024×1024 white canvas at 52% scale
  • Overwrites assets/images/logo.png  (backs up the original first)
  • Also writes assets/images/logo_splash.png at 38% scale
    (smaller, used only for the native splash on older Android)

After running:
  dart run flutter_native_splash:create
  dart run flutter_launcher_icons
"""

from PIL import Image
import shutil, os

SRC         = "assets/images/logo.png"
BACKUP      = "assets/images/logo_original.png"
OUT_ICON    = "assets/images/logo.png"          # launcher icon (52% scale)
OUT_SPLASH  = "assets/images/logo_splash.png"   # native splash  (38% scale)
CANVAS      = 1024


def pad(src_path: str, out_path: str, scale: float, bg: tuple = (255, 255, 255, 255)):
    img = Image.open(src_path).convert("RGBA")

    # Calculate logo size inside canvas
    logo_size = int(CANVAS * scale)
    img = img.resize((logo_size, logo_size), Image.LANCZOS)

    # Paste centred on white canvas
    canvas = Image.new("RGBA", (CANVAS, CANVAS), bg)
    offset = (CANVAS - logo_size) // 2
    canvas.paste(img, (offset, offset), img)

    # Save as RGBA PNG
    canvas.save(out_path, "PNG")
    print(f"  ✅  {out_path}  ({logo_size}px logo on {CANVAS}px canvas — {int(scale*100)}% scale)")


if __name__ == "__main__":
    if not os.path.exists(SRC):
        print(f"❌  Could not find {SRC}. Run this from your Flutter project root.")
        exit(1)

    # Backup original once
    if not os.path.exists(BACKUP):
        shutil.copy(SRC, BACKUP)
        print(f"  📦  Original backed up → {BACKUP}")

    print("\nGenerating padded logo files...\n")
    pad(BACKUP, OUT_ICON,   scale=0.63)   # launcher icon — generous padding
    pad(BACKUP, OUT_SPLASH, scale=0.38)   # native splash — extra padding

    print("\n✅  Done. Now run:")
    print("    dart run flutter_native_splash:create")
    print("    dart run flutter_launcher_icons\n")