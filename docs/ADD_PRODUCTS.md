# Quick Start: Adding Products to B3 Stores App

## To Add a New Product

### 1. Edit the JSON File

Open `/PickleStore/Resources/products.json` and add your product:

```json
{
  "id": "00000000-0000-0000-0000-000000000XXX",
  "name": "Your Product Name",
  "description": "Product description from website",
  "category": "Pickles",
  "rating": 4.5,
  "reviewCount": 0,
  "imageName": "your-product-image",
  "tags": ["Tag1", "Tag2"],
  "variants": [
    {
      "id": "00000000-0000-0000-0000-000000000XX1",
      "weight": 0.5,
      "weightLabel": "500gm",
      "price": 10.00,
      "originalPrice": null,
      "sku": "PRODUCT-500"
    }
  ]
}
```

**Important:** 
- Increment the ID numbers for each new product
- Match `imageName` to your asset name (without extension)

### 2. Add Product Image

1. Open **Xcode**
2. Navigate to: `PickleStore` → `PickleStore` → `Assets.xcassets`
3. Right-click in the left panel → **New Image Set**
4. Name it exactly as `imageName` in JSON (e.g., "mirchi-pickle")
5. Drag your image file into the **1x** slot

### 3. Rebuild and Run

In Terminal:
```bash
cd /Users/vakula/repos/PickleStoreApp/PickleStore
xcodebuild -project PickleStore.xcodeproj -scheme PickleStore build
```

Or press **⌘ + B** in Xcode.

---

## Current Products in JSON

The app now includes:
1. **Mirchi Pickle** - 2 variants (500gm £10, 1KG £15)
2. **Mango Pickle** - 2 variants
3. **Gongura Pickle** - 2 variants
4. **Mixed Vegetable Pickle** - 2 variants
5. **Lemon Pickle** - 2 variants

---

## Next Steps

For full details on:
- Product field descriptions
- Scraping products from bharatbeyondborders.com
- Building an admin portal
- Firebase integration

See: **[ADMIN_GUIDE.md](./ADMIN_GUIDE.md)**

---

## Need Help?

Common issues:
- **Product not showing:** Check `imageName` matches asset name exactly
- **App crashes:** Validate JSON syntax at jsonlint.com
- **Wrong price:** Make sure variant prices are numbers (no quotes)

Contact for admin portal development or web scraping automation!