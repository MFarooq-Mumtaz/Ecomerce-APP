param(
  [string]$ProjectId = "avero-147cb"
)

$ErrorActionPreference = "Stop"

function Get-FirebaseAccessToken {
  $loginJson = firebase login:list --json | ConvertFrom-Json
  if (-not $loginJson.result -or -not $loginJson.result[0].tokens.access_token) {
    throw "Firebase CLI is not logged in. Run firebase login first."
  }

  return $loginJson.result[0].tokens.access_token
}

function New-FirestoreString([string]$Value) {
  return @{ stringValue = $Value }
}

function New-FirestoreBool([bool]$Value) {
  return @{ booleanValue = $Value }
}

function New-FirestoreInt([int]$Value) {
  return @{ integerValue = "$Value" }
}

function New-FirestoreDouble([double]$Value) {
  return @{ doubleValue = $Value }
}

function New-FirestoreTimestamp([string]$Value) {
  return @{ timestampValue = $Value }
}

function Test-CollectionIsEmpty {
  param(
    [string]$Collection,
    [hashtable]$Headers,
    [string]$BaseUrl
  )

  $uri = "$BaseUrl/$Collection`?pageSize=1"
  try {
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $Headers
    return -not $response.documents
  } catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 404) {
      return $true
    }
    throw
  }
}

function New-Document {
  param(
    [string]$Collection,
    [string]$DocumentId,
    [hashtable]$Fields,
    [hashtable]$Headers,
    [string]$BaseUrl
  )

  $uri = "$BaseUrl/$Collection/$DocumentId`?currentDocument.exists=false"
  $body = @{ fields = $Fields } | ConvertTo-Json -Depth 10
  Invoke-RestMethod -Method Patch -Uri $uri -Headers $Headers -Body $body -ContentType "application/json" | Out-Null
}

$token = Get-FirebaseAccessToken
$headers = @{ Authorization = "Bearer $token" }
$baseUrl = "https://firestore.googleapis.com/v1/projects/$ProjectId/databases/(default)/documents"

$categoriesEmpty = Test-CollectionIsEmpty -Collection "categories" -Headers $headers -BaseUrl $baseUrl
$productsEmpty = Test-CollectionIsEmpty -Collection "products" -Headers $headers -BaseUrl $baseUrl

if (-not ($categoriesEmpty -and $productsEmpty)) {
  Write-Host "Skipped: categories or products collection is not empty. No documents were written."
  exit 0
}

$now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

$categories = @(
  @{ id = "hoodies"; name = "Hoodies"; imageUrl = "assets/images/demo_catalog/category_hoodies.png"; sortOrder = 1 },
  @{ id = "shorts"; name = "Shorts"; imageUrl = "assets/images/demo_catalog/category_shorts.png"; sortOrder = 2 },
  @{ id = "shoes"; name = "Shoes"; imageUrl = "assets/images/demo_catalog/category_shoes.png"; sortOrder = 3 },
  @{ id = "bag"; name = "Bag"; imageUrl = "assets/images/demo_catalog/category_bag.png"; sortOrder = 4 },
  @{ id = "accessories"; name = "Accessories"; imageUrl = "assets/images/demo_catalog/category_accessories.jpeg"; sortOrder = 5 }
)

$products = @(
  @{ id = "mens-harrington-jacket"; name = "Men's Harrington Jacket"; description = "Lightweight everyday jacket with a clean relaxed fit."; price = 148.00; categoryId = "hoodies"; categoryName = "Hoodies"; imageUrl = "assets/images/demo_catalog/product_01.png"; stock = 18 },
  @{ id = "max-cirro-mens-slides"; name = "Max Cirro Men's Slides"; description = "Comfort-first slide sandals for casual days."; price = 55.00; compareAtPrice = 100.97; categoryId = "shoes"; categoryName = "Shoes"; imageUrl = "assets/images/demo_catalog/product_02.png"; stock = 24 },
  @{ id = "mens-coaches-jacket"; name = "Men's Coaches Jacket"; description = "Minimal layer with a structured streetwear profile."; price = 66.97; categoryId = "hoodies"; categoryName = "Hoodies"; imageUrl = "assets/images/demo_catalog/product_03.png"; stock = 16 },
  @{ id = "nike-unscripted"; name = "Nike Unscripted"; description = "Clean performance-inspired casual essential."; price = 120.00; categoryId = "shorts"; categoryName = "Shorts"; imageUrl = "assets/images/demo_catalog/product_04.png"; stock = 11 },
  @{ id = "nike-sb"; name = "Nike SB"; description = "Skate-inspired staple with everyday comfort."; price = 100.00; categoryId = "shoes"; categoryName = "Shoes"; imageUrl = "assets/images/demo_catalog/product_05.png"; stock = 20 },
  @{ id = "nike-windrunner"; name = "Nike Windrunner"; description = "Classic lightweight outerwear for daily movement."; price = 52.97; categoryId = "hoodies"; categoryName = "Hoodies"; imageUrl = "assets/images/demo_catalog/product_06.png"; stock = 14 },
  @{ id = "relaxed-hoodie"; name = "Relaxed Hoodie"; description = "Soft fleece hoodie with a premium everyday shape."; price = 72.00; categoryId = "hoodies"; categoryName = "Hoodies"; imageUrl = "assets/images/demo_catalog/product_07.png"; stock = 22 },
  @{ id = "everyday-cap"; name = "Everyday Cap"; description = "Adjustable cap built for simple daily styling."; price = 28.00; categoryId = "accessories"; categoryName = "Accessories"; imageUrl = "assets/images/demo_catalog/product_08.png"; stock = 35 },
  @{ id = "leather-crossbody-bag"; name = "Leather Crossbody Bag"; description = "Compact carry bag for essentials and travel."; price = 89.00; categoryId = "bag"; categoryName = "Bag"; imageUrl = "assets/images/demo_catalog/category_bag.png"; stock = 12 },
  @{ id = "classic-watch"; name = "Classic Watch"; description = "Minimal wristwatch with a clean modern finish."; price = 135.00; categoryId = "accessories"; categoryName = "Accessories"; imageUrl = "assets/images/demo_catalog/category_accessories.jpeg"; stock = 9 }
)

foreach ($category in $categories) {
  New-Document -Collection "categories" -DocumentId $category.id -Headers $headers -BaseUrl $baseUrl -Fields @{
    name = New-FirestoreString $category.name
    imageUrl = New-FirestoreString $category.imageUrl
    sortOrder = New-FirestoreInt $category.sortOrder
    isActive = New-FirestoreBool $true
  }
}

foreach ($product in $products) {
  $fields = @{
    name = New-FirestoreString $product.name
    description = New-FirestoreString $product.description
    price = New-FirestoreDouble $product.price
    imageUrl = New-FirestoreString $product.imageUrl
    categoryId = New-FirestoreString $product.categoryId
    categoryName = New-FirestoreString $product.categoryName
    vendorId = New-FirestoreString "demo-vendor-avero"
    stock = New-FirestoreInt $product.stock
    isActive = New-FirestoreBool $true
    createdAt = New-FirestoreTimestamp $now
  }

  if ($product.ContainsKey("compareAtPrice")) {
    $fields.compareAtPrice = New-FirestoreDouble $product.compareAtPrice
  }

  New-Document -Collection "products" -DocumentId $product.id -Headers $headers -BaseUrl $baseUrl -Fields $fields
}

Write-Host "Seeded $($categories.Count) categories and $($products.Count) products into project $ProjectId."
