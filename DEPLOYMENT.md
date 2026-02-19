# Deployment & App Store Submission Guide

## Production Architecture (Current)

- App host: Vercel
- Production URL: `https://delivery-date-estimator-project.vercel.app`
- Shopify app config: `delivery-date-estimator/shopify.app.toml`
- Database: Prisma (currently SQLite; migrate to managed Postgres before App Store scale)

## Phase 1: Deploy App Server on Vercel

From repository root:

```bash
npm run verify:launch
npm run build
vercel --prod
```

Verify:

```bash
curl -I https://delivery-date-estimator-project.vercel.app
```

Expected: `HTTP/2 200`

### Required Vercel environment variables

Set these on Production:

- `SHOPIFY_API_KEY`
- `SHOPIFY_API_SECRET`
- `SHOPIFY_APP_URL=https://delivery-date-estimator-project.vercel.app`

Optional overrides:

- `SHOPIFY_BILLING_TEST_MODE=false` (force live billing mode explicitly)

### Sync Shopify app configuration

From `delivery-date-estimator/`:

```bash
npm run deploy -- --force
```

This pushes `shopify.app.toml` settings (URL, redirects, scopes, webhooks, app proxy).

Note:

- Runtime scopes are fixed to least-privilege `read_products` in code.
- Billing mode defaults to test outside production and live in production.

## Phase 1.5: Database Upgrade (Required)

Before public App Store scale, move from SQLite to managed Postgres:

1. Provision Postgres (Neon, Supabase, Railway, or other managed service).
2. Set `DATABASE_URL` in Vercel Production.
3. Update Prisma datasource provider to `postgresql`.
4. Run migrations against Postgres.

This prevents session/config data loss on serverless instances.

---

## Phase 2: Prepare App Store Listing

Go to: https://partners.shopify.com → Apps → Your App → Distribution

1. **Choose distribution:** Select "Shopify App Store"

2. **App listing info:**
   - Copy text from `APP_STORE_LISTING.md` in this project
   - Fill in all fields

3. **Screenshots (required, minimum 3):**
   
   HOW TO TAKE GOOD SCREENSHOTS:
   - Install the app on your dev store
   - Add some products with images  
   - Add the widget to a product page
   - Take full-page screenshots showing the widget
   - Screenshot the theme editor showing the settings panel
   - Screenshot mobile view
   
   Recommended sizes: 1600x900px or 1200x800px
   
   Tools: Chrome DevTools (Cmd+Shift+M for mobile), or CleanShot/Screenshot app

4. **App icon:** 
   - 1200x1200px square PNG
   - Simple, clean — a truck icon or clock with your brand color works great
   - Use Figma or Canva to make one quickly

5. **Privacy policy URL:**
   - Use: `https://delivery-date-estimator-project.vercel.app/privacy-policy`

6. **Terms of service URL:**
   - Use: `https://delivery-date-estimator-project.vercel.app/terms-of-service`

7. **Pricing:**
   - Set up Free, Pro ($7.99), and Premium ($14.99) plans
   - Make sure billing config is in your `shopify.app.toml`

---

## Phase 3: Pre-Submission Checklist

Before hitting "Submit for Review":

- [ ] App works on a clean dev store (fresh install)
- [ ] Widget displays correctly on product pages
- [ ] Countdown timer counts down and updates
- [ ] All settings work in the theme editor
- [ ] Widget looks good on mobile
- [ ] Widget works with Dawn theme (Shopify's default)
- [ ] Billing flow works (test charges)
- [ ] Privacy policy is accessible
- [ ] App icon uploaded (1200x1200)
- [ ] At least 3 screenshots uploaded
- [ ] All listing text filled in
- [ ] Support email is set and working
- [ ] `SHOPIFY_BILLING_TEST_MODE=false` set in Vercel Production
- [ ] Scope set to least privilege (`read_products`)
- [ ] Managed Postgres configured for production

---

## Phase 4: Submit for Review

1. Go to Partners Dashboard → Apps → Your App
2. Click "Submit for review"  
3. Include test instructions:
   
   ```
   Test Instructions:
   1. Install the app
   2. Go to Online Store → Themes → Customize
   3. Navigate to a product page template
   4. Click "Add block" in the product section
   5. Select "Delivery Date Estimator"  
   6. The widget appears with estimated delivery date and countdown
   7. Adjust settings (cutoff hour, shipping days, colors) to verify customization
   8. Save and preview on the storefront
   ```

4. Submit

**Review typically takes 3-7 business days.**
Shopify may request changes — respond quickly to stay in the queue.

---

## Phase 5: Post-Launch

### First Week
- Monitor for any bug reports
- Respond to every review within 24 hours
- Ask early users for reviews (politely, in-app)

### First Month  
- Add features based on feedback
- Track install/uninstall rates in Partners Dashboard
- Consider running Shopify App Store Ads ($50-100/month budget to start)

### Ongoing
- Ship updates regularly (shows activity in the app store)
- Keep adding value: better onboarding, smarter date rules, deeper analytics
- Good reviews compound — each one brings more installs

---

## Useful Links

- Partners Dashboard: https://partners.shopify.com
- App Store listing requirements: https://shopify.dev/docs/apps/store/requirements
- Billing API docs: https://shopify.dev/docs/apps/billing
- Theme Extensions docs: https://shopify.dev/docs/apps/build/online-store/theme-app-extensions
- Vercel docs: https://vercel.com/docs
- Shopify CLI reference: https://shopify.dev/docs/apps/tools/cli
