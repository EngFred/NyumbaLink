from PIL import Image
import os

ICON_SRC    = "assets/images/new_logo.png"
SPLASH_SRC  = "assets/images/logo_with_title.jpeg"
OUT_ICON    = "assets/images/logo.png"
OUT_SPLASH  = "assets/images/logo_splash.png"
CANVAS      = 1024


def pad(src_path: str, out_path: str, scale: float, bg: tuple = (255, 255, 255, 255)):
    img = Image.open(src_path).convert("RGBA")
    logo_size = int(CANVAS * scale)
    img = img.resize((logo_size, logo_size), Image.LANCZOS)
    canvas = Image.new("RGBA", (CANVAS, CANVAS), bg)
    offset = (CANVAS - logo_size) // 2
    canvas.paste(img, (offset, offset), img)
    canvas.save(out_path, "PNG")
    print(f"  ✅  {out_path}  ({logo_size}px logo on {CANVAS}px canvas — {int(scale*100)}% scale)")


if __name__ == "__main__":
    for src in [ICON_SRC, SPLASH_SRC]:
        if not os.path.exists(src):
            print(f"❌  Could not find {src}. Run this from your Flutter project root.")
            exit(1)

    print("\nGenerating padded logo files...\n")
    pad(ICON_SRC,   OUT_ICON,   scale=0.72)
    pad(SPLASH_SRC, OUT_SPLASH, scale=0.55)

    print("\n✅  Done. Now run:")
    print("    dart run flutter_native_splash:create")
    print("    dart run flutter_launcher_icons\n")