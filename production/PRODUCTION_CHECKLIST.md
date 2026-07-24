# Production Readiness Checklist

Kenya & global MVP launch — payments, compliance, infrastructure, onboarding.

---

## 1. Payments

### Local (Kenya — KES)

- **M-PESA Integration**: Use Paystack or Safaricom Daraja API for STK pushes
- **Callback reliability**: Handle async M-PESA webhooks with timeout retries (Safaricom/Airtel network drops)
- **Test both networks**: Safaricom and Airtel M-PESA have different behaviors

### Global (USD/EUR)

- **Merchant of Record (MoR)**: Lemon Squeezy, Paddle, or Paystack (International Cards)
- MoRs handle VAT/Sales tax calculation and remittance — no manual tax compliance needed

### Tax Compliance

- **KRA eTIMS**: If invoicing Kenyan B2B clients, check if eTIMS compliance is required for receipts
- **VAT**: MoR handles international VAT; local B2B invoicing needs separate handling

---

## 2. Compliance

### ODPC (Kenya — Data Protection Act 2019)

- [ ] Register with ODPC as Data Controller/Processor
- [ ] Cross-border data transfer compliance (cloud servers outside Kenya)
- [ ] Self-service data export for users
- [ ] Account deletion ("Right to be Forgotten")

### GDPR (Global)

- [ ] Privacy policy covering data collection, storage, and usage
- [ ] Cookie consent (if applicable)
- [ ] Data Processing Agreement (DPA) with service providers
- [ ] Right to erasure implementation

### AI Disclaimers

- Include prominent disclaimers: AI-generated outputs are for informational purposes only
- Not a substitute for professional legal/financial/medical advice

---

## 3. Infrastructure & Latency

### Server Region

- **Primary audience (Kenya/East Africa)**: AWS `af-south-1` (Cape Town) or Cloudflare edge
- **Target**: API responses under 100ms for Kenyan mobile users

### Low-Bandwidth UX

- [ ] React Native app handles intermittent network drops
- [ ] Optimistic UI updates for critical actions
- [ ] Cache fetched content in local storage
- [ ] Compress documents/PDFs before serving on mobile data

### CDN Strategy

- Static assets via Cloudflare / Vercel / AWS CloudFront
- API responses cached at edge where possible

---

## 4. Multi-Channel Onboarding

### Verification

| Channel | Tool | Use case |
|---|---|---|
| **Email** | Resend, Postmark, SendGrid | Global users |
| **SMS OTP** | Africa's Talking, Twilio | Kenya/East Africa (standard practice) |

### DNS Config (Email)

- [ ] SPF record configured
- [ ] DKIM record configured
- [ ] DMARC record configured

### Localized UX

- [ ] Search suggestions reflect local legal frameworks
- [ ] Default views show relevant local + international benchmarks
- [ ] Empty states include helpful local context

---

## 5. Product Analytics

### Privacy-First Analytics

- **PostHog** or **Plausible** — GDPR/ODPC compliant
- Track: Landing Page → Search Query → Document Saved → Subscription

### Customer Support

- Lightweight in-app feedback modal
- WhatsApp Business API (for Kenyan users)
- Crisp or Slack webhook for bug reports

---

## Summary Matrix

| Domain | Kenya | Global | Solo Dev Tool |
|---|---|---|---|
| **Payments** | M-PESA (Paystack / Daraja) | Cards / Apple Pay | Paystack / Lemon Squeezy |
| **Compliance** | ODPC + DPA 2019 | GDPR | Termly / templates |
| **Verification** | SMS OTP (Africa's Talking) | Email (Resend) | Supabase Auth |
| **Hosting** | AWS Cape Town / Cloudflare | Global CDN | Cloudflare / serverless |
| **Support** | In-app / WhatsApp | Email / helpdesk | Crisp / Slack |

---

## Common Gotchas

| Gotcha | Solution |
|---|---|
| M-PESA callback timeout | Implement retry logic with exponential backoff |
| ODPC registration delay | Start process early — approval takes weeks |
| Mobile data bloat | Compress all media, enable lazy loading |
| SMS delivery failure | Fallback to email OTP for failed SMS sends |
| GDPR cookie banner | Required only if tracking cookies — server-side analytics avoid this |

---

## Further Reading

- [Production Checklist (full doc)](../reference/pdfs/Production%20Readiness%20Checklist_%20Kenya%20&%20Global%20MVP%20Launch.docx)
- [Safaricom Daraja API](https://developer.safaricom.co.ke)
- [Paystack Docs](https://paystack.com/docs)
- [Lemon Squeezy Docs](https://docs.lemonsqueezy.com)
