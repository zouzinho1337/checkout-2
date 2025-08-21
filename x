import React, { useMemo, useState } from "react";
import { motion } from "framer-motion";

// --- Brand tokens (Resurs-inspired) ---
const brand = {
  primary: "#0E8F7F", // teal/green
  primaryDark: "#0B7266",
  accent: "#F4F9F7",
  text: "#0F172A", // slate-900
  muted: "#475569", // slate-600
  border: "#E2E8F0", // slate-200
};

// --- Tiny helpers ---
const currency = (n) => new Intl.NumberFormat("sv-SE", { style: "currency", currency: "SEK" }).format(n);

// Use official Resurs Bank logo via CDN with fallback to local file
const ResursLogo = ({ className = "h-6 w-auto" }) => (
  <img
    src="https://www.resursbank.se/themes/custom/resursbank/logo.svg"
    onError={(e) => {
      e.currentTarget.onerror = null;
      e.currentTarget.src = "/resurs-logo.png"; // fallback: local file in public/
    }}
    alt="Resurs Bank"
    className={className}
    width={120}
    height={40}
  />
);

const Step = ({ index, title, current }) => {
  const active = current === index;
  const done = current > index;
  const base = "h-8 w-8 grid place-items-center rounded-full text-sm font-semibold border";
  const className = `${base} ${!active && !done ? "bg-white text-slate-500 border-slate-300" : ""}`;
  const style = active
    ? { backgroundColor: brand.primary, color: "#fff", borderColor: "transparent" }
    : done
    ? { backgroundColor: brand.accent, color: brand.primary, borderColor: brand.primary }
    : {};
  return (
    <div className="flex items-center gap-3">
      <div className={className} style={style}>
        {index}
      </div>
      <div className={`text-sm sm:text-base font-semibold ${active ? "" : "text-slate-500"}`} style={active ? { color: brand.text } : {}}>
        {title}
      </div>
    </div>
  );
};

const DeliveryOption = ({ id, title, subtitle, price, selected, onChange, badge }) => (
  <label htmlFor={id} className={`block rounded-2xl border p-4 sm:p-5 cursor-pointer transition-shadow ${selected ? "shadow-lg border-emerald-400" : "hover:shadow-sm"}`}>
    <div className="flex items-start gap-4">
      <input id={id} name="delivery" type="radio" className="mt-1 h-5 w-5" checked={selected} onChange={onChange} />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-3">
          <p className="font-semibold text-slate-900">{title}</p>
          {badge && (
            <span className="text-xs px-2 py-0.5 rounded-full" style={{ background: brand.accent, color: brand.primary, border: `1px solid ${brand.primary}` }}>
              {badge}
            </span>
          )}
        </div>
        <p className="text-sm text-slate-600 mt-1">{subtitle}</p>
      </div>
      <div className="shrink-0 font-semibold">{price === 0 ? "0 kr" : `${price} kr`}</div>
    </div>
  </label>
);

const PaymentTile = ({ id, title, subtitle, selected, onChange, rightIcon, children }) => (
  <label htmlFor={id} className={`block rounded-2xl border p-4 sm:p-5 cursor-pointer transition-shadow ${selected ? "shadow-lg border-emerald-400" : "hover:shadow-sm"}`}>
    <div className="flex items-start gap-4">
      <input id={id} name="payment" type="radio" className="mt-1 h-5 w-5" checked={selected} onChange={onChange} />
      <div className="flex-1 min-w-0">
        <p className="font-semibold text-slate-900">{title}</p>
        {subtitle && <p className="text-sm text-slate-600 mt-1">{subtitle}</p>}
        {selected && children}
      </div>
      {rightIcon}
    </div>
  </label>
);

const TextField = ({ label, value, onChange, type = "text", placeholder, required }) => (
  <div className="grid gap-1.5">
    <label className="text-sm font-medium text-slate-800">{label}</label>
    <input
      value={value}
      onChange={(e) => onChange(e.target.value)}
      type={type}
      placeholder={placeholder}
      required={required}
      className="rounded-xl border bg-white px-3 py-2.5 outline-none focus:ring-4 focus:ring-emerald-100"
    />
  </div>
);

const SummaryRow = ({ label, value, bold }) => (
  <div className="flex justify-between text-sm sm:text-base">
    <span className={`text-slate-600 ${bold ? "font-semibold text-slate-800" : ""}`}>{label}</span>
    <span className={`text-slate-900 ${bold ? "font-semibold" : ""}`}>{value}</span>
  </div>
);

const CartList = ({ items }) => (
  <div className="grid gap-4">
    {items.map((item) => (
      <div key={item.id} className="flex items-center gap-4 rounded-2xl border p-3">
        <div className="h-16 w-16 rounded-xl bg-slate-100" />
        <div className="flex-1 min-w-0">
          <p className="truncate font-medium">{item.title}</p>
          <p className="text-sm text-slate-600">{item.qty} × {currency(item.price)}</p>
        </div>
        <div className="font-semibold">{currency(item.qty * item.price)}</div>
      </div>
    ))}
  </div>
);

export default function ResursCheckout() {
  // --- Demo state ---
  const [step, setStep] = useState(1);
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [name, setName] = useState("");
  const [street, setStreet] = useState("");
  const [zip, setZip] = useState("");
  const [city, setCity] = useState("");
  const [delivery, setDelivery] = useState("morning");
  const [payment, setPayment] = useState("resurs_direct");
  const [card, setCard] = useState({ number: "", mm: "", yy: "", cvc: "" });

  const items = [
    { id: 1, title: "Bok: Systemdesign i praktiken", price: 179, qty: 1 },
    { id: 2, title: "Anteckningsblock A5", price: 29, qty: 1 },
  ];

  const shippingPrice = useMemo(() => (delivery === "economy" ? 35 : delivery === "evening" ? 59 : 39), [delivery]);
  const subtotal = items.reduce((s, i) => s + i.price * i.qty, 0);
  const total = subtotal + shippingPrice;

  const canContinueAddress = email && name && street && zip && city;

  const handlePay = (e) => {
    e.preventDefault();
    alert(`Klar för betalning (demo) via ${payment.replace("_", " ")}.\nTotalt: ${currency(total)}`);
  };

  return (
    <div className="min-h-screen w-full" style={{ background: brand.accent }}>
      <header className="sticky top-0 z-40 border-b bg-white/90 backdrop-blur">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 py-3 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <ResursLogo className="h-8" />
            <span className="sr-only">Resurs-style Checkout</span>
          </div>
          <nav className="hidden md:flex items-center gap-6 text-sm text-slate-600">
            <a href="#" className="hover:text-slate-900">Kundtjänst</a>
            <a href="#" className="hover:text-slate-900">Köpvillkor</a>
            <a href="#" className="hover:text-slate-900">Integritet</a>
          </nav>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 sm:px-6 py-10 grid lg:grid-cols-[1fr_420px] gap-8">
        {/* Left column */}
        <div className="grid gap-8">
          {/* Steps */}
          <div className="grid gap-4 sm:gap-6">
            <div className="flex items-center gap-6">
              <Step index={1} title="Leveranssätt" current={step} />
              <div className="h-px flex-1 bg-slate-200" />
              <Step index={2} title="Adress" current={step} />
              <div className="h-px flex-1 bg-slate-200" />
              <Step index={3} title="Betalning" current={step} />
            </div>

            {/* Step 1: Delivery */}
            {step === 1 && (
              <motion.section initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="rounded-3xl bg-white p-5 sm:p-7 border">
                <div className="grid gap-6">
                  <div className="grid sm:grid-cols-2 gap-4">
                    <TextField label="Postnummer" value={zip} onChange={setZip} placeholder="Ange ditt postnummer" />
                    <TextField label="Stad" value={city} onChange={setCity} placeholder="Ort" />
                  </div>
                  <div className="grid gap-3">
                    <p className="font-semibold">Leveransalternativ</p>
                    <div className="grid gap-3">
                      <DeliveryOption id="morning" title="Hemleverans på morgonen" subtitle="Levereras före 07:00. Hängs i vädertålig påse om paketet inte får plats." price={39} selected={delivery === "morning"} onChange={() => setDelivery("morning")} badge="Fossilfri" />
                      <DeliveryOption id="locker" title="Leverans till paketskåp" subtitle="Leveranstid 1–2 dagar" price={39} selected={delivery === "locker"} onChange={() => setDelivery("locker")} />
                      <DeliveryOption id="agent" title="Leverans till ombud" subtitle="Leveranstid 2–3 dagar" price={39} selected={delivery === "agent"} onChange={() => setDelivery("agent")} />
                      <DeliveryOption id="evening" title="Hemleverans på kvällen" subtitle="Leveranstid 17:00–22:00" price={59} selected={delivery === "evening"} onChange={() => setDelivery("evening")} />
                      <DeliveryOption id="economy" title="Ekonomifrakt" subtitle="Längre leveranstid" price={35} selected={delivery === "economy"} onChange={() => setDelivery("economy")} />
                    </div>
                  </div>

                  <div className="flex justify-end">
                    <button
                      className="rounded-2xl px-5 py-3 font-semibold text-white shadow-sm"
                      style={{ backgroundColor: brand.primary }}
                      onClick={() => setStep(2)}
                    >
                      Fortsätt
                    </button>
                  </div>
                </div>
              </motion.section>
            )}

            {/* Step 2: Address */}
            {step === 2 && (
              <motion.section initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="rounded-3xl bg-white p-5 sm:p-7 border">
                <div className="grid gap-6">
                  <div className="grid sm:grid-cols-2 gap-4">
                    <TextField label="Mejladress" value={email} onChange={setEmail} type="email" placeholder="namn@exempel.se" required />
                    <TextField label="Mobilnummer" value={phone} onChange={setPhone} type="tel" placeholder="07x-xxx xx xx" />
                  </div>

                  <div className="grid sm:grid-cols-2 gap-4">
                    <TextField label="Namn" value={name} onChange={setName} placeholder="För- och efternamn" required />
                    <TextField label="Gatuadress" value={street} onChange={setStreet} placeholder="Adress" required />
                  </div>

                  <div className="grid sm:grid-cols-3 gap-4">
                    <TextField label="Postnummer" value={zip} onChange={setZip} placeholder="311 72" required />
                    <TextField label="Stad" value={city} onChange={setCity} placeholder="Falkenberg" required />
                    <div className="grid gap-1.5">
                      <label className="text-sm font-medium text-slate-800">Land</label>
                      <input value="Sverige" readOnly className="rounded-xl border bg-slate-50 px-3 py-2.5" />
                    </div>
                  </div>

                  <div className="flex justify-between">
                    <button className="rounded-2xl px-5 py-3 font-semibold border" onClick={() => setStep(1)}>Tillbaka</button>
                    <button
                      className={`rounded-2xl px-5 py-3 font-semibold text-white shadow-sm disabled:opacity-50`}
                      style={{ backgroundColor: brand.primary }}
                      disabled={!canContinueAddress}
                      onClick={() => setStep(3)}
                    >
                      Fortsätt
                    </button>
                  </div>
                </div>
              </motion.section>
            )}

            {/* Step 3: Payment */}
            {step === 3 && (
              <motion.section initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="rounded-3xl bg-white p-5 sm:p-7 border">
                <form className="grid gap-6" onSubmit={handlePay}>
                  <div className="grid gap-3">
                    <p className="font-semibold">Betalningssätt (via Resurs)</p>
                    <PaymentTile id="resurs_direct" title="Direkt" subtitle="Kort, Swish och bank" selected={payment === "resurs_direct"} onChange={() => setPayment("resurs_direct")} rightIcon={<ResursLogo className="h-6" />}>
                      <div className="mt-3 flex flex-wrap gap-3 text-xs text-slate-600">
                        <span className="rounded-md border px-2 py-1">VISA</span>
                        <span className="rounded-md border px-2 py-1">Mastercard</span>
                        <span className="rounded-md border px-2 py-1">BankID</span>
                        <span className="rounded-md border px-2 py-1">Swish</span>
                      </div>
                    </PaymentTile>

                    <PaymentTile id="resurs_invoice" title="Faktura" subtitle="30 dagar, månadsfaktura" selected={payment === "resurs_invoice"} onChange={() => setPayment("resurs_invoice")} rightIcon={<ResursLogo className="h-6" />}>
                      <p className="mt-3 text-sm text-slate-600">Betala senare med faktura från Resurs efter sedvanlig kreditprövning.</p>
                    </PaymentTile>

                    <PaymentTile id="resurs_card" title="Betala med kort" subtitle="Fyll i kortuppgifter" selected={payment === "resurs_card"} onChange={() => setPayment("resurs_card")} rightIcon={<ResursLogo className="h-6" />}>
                      <div className="mt-4 grid sm:grid-cols-2 gap-3">
                        <TextField label="Kortnummer" value={card.number} onChange={(v) => setCard({ ...card, number: v })} placeholder="4242 4242 4242 4242" />
                        <div className="grid grid-cols-3 gap-3">
                          <TextField label="MM" value={card.mm} onChange={(v) => setCard({ ...card, mm: v })} placeholder="MM" />
                          <TextField label="ÅÅ" value={card.yy} onChange={(v) => setCard({ ...card, yy: v })} placeholder="ÅÅ" />
                          <TextField label="CVC" value={card.cvc} onChange={(v) => setCard({ ...card, cvc: v })} placeholder="CVC" />
                        </div>
                      </div>
                    </PaymentTile>
                  </div>

                  <div className="flex justify-between">
                    <button type="button" className="rounded-2xl px-5 py-3 font-semibold border" onClick={() => setStep(2)}>Tillbaka</button>
                    <button type="submit" className="rounded-2xl px-6 py-3 font-semibold text-white shadow-sm" style={{ backgroundColor: brand.primary }}>
                      Betala köp
                    </button>
                  </div>
                </form>
              </motion.section>
            )}
          </div>
        </div>

        {/* Right column: Order summary */}
        <aside className="lg:sticky lg:top-20 h-max">
          <div className="rounded-3xl border bg-white p-5 sm:p-7 grid gap-6">
            <div className="flex items-center gap-3">
              <div className="h-9 w-9 grid place-items-center rounded-full" style={{ background: brand.accent, border: `1px solid ${brand.primary}`, color: brand.primary }}>SEK</div>
              <div>
                <p className="font-semibold text-slate-900">Orderöversikt</p>
                <p className="text-sm text-slate-600">Inkl. moms & frakt</p>
              </div>
            </div>

            <CartList items={items} />

            <div className="h-px bg-slate-200" />
            <div className="grid gap-2">
              <SummaryRow label="Delsumma" value={currency(subtotal)} />
              <SummaryRow label="Frakt" value={currency(shippingPrice)} />
              <SummaryRow label="Totalt" value={currency(total)} bold />
            </div>

            <div className="text-xs text-slate-500">
              Genom att klicka på <span className="font-semibold">Betala köp</span> godkänner du villkor, bekräftar dataskyddsinformation och accepterar kreditprövning vid behov.
            </div>
          </div>
        </aside>
      </main>

      <footer className="border-t bg-white">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 py-8 grid sm:grid-cols-3 gap-6 text-sm text-slate-600">
          <div className="grid gap-3">
            <p className="font-semibold text-slate-800">Säkra betalningar</p>
            <p>Drivs av <span className="font-semibold" style={{ color: brand.primary }}>Resurs</span>. Vi stödjer BankID, Swish och kort.</p>
          </div>
          <div className="grid gap-3">
            <p className="font-semibold text-slate-800">Kundservice</p>
            <p>Mån–Fre 09–17. Mejla oss på support@example.se</p>
          </div>
          <div className="grid gap-3">
            <p className="font-semibold text-slate-800">Juridik</p>
            <p>Allmänna villkor • Integritetspolicy • Cookies</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
