import type { MetaFunction } from "react-router";
import { Link } from "react-router";

export const meta: MetaFunction = () => [
  { title: "Privacy Policy | Delivery Date Estimator" },
];

const containerStyle = {
  maxWidth: 880,
  margin: "0 auto",
  padding: "44px 24px",
  lineHeight: 1.7,
  color: "#111827",
  fontFamily:
    "Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
};

export default function PrivacyPolicyPage() {
  return (
    <main style={containerStyle}>
      <h1>Privacy Policy</h1>
      <p>
        Last updated: February 18, 2026
      </p>

      <h2>1. Information We Collect</h2>
      <p>
        We collect store-level configuration and analytics needed to provide the
        Delivery Date Estimator app, including shipping settings and aggregated
        event counters.
      </p>

      <h2>2. How We Use Information</h2>
      <p>
        Data is used to calculate delivery estimates, render storefront widgets,
        support billing features, and improve app reliability.
      </p>

      <h2>3. Data Sharing</h2>
      <p>
        We do not sell merchant data. We only share data with service providers
        required to run the app infrastructure.
      </p>

      <h2>4. Data Retention</h2>
      <p>
        We retain data only as long as needed to operate the app and meet legal
        obligations. Data is removed when a store uninstalls, subject to backup
        retention windows.
      </p>

      <h2>5. Security</h2>
      <p>
        We use reasonable safeguards to protect data in transit and at rest.
      </p>

      <h2>6. Contact</h2>
      <p>
        For privacy questions, contact{" "}
        <a href="mailto:support@deliverydateestimator.app">
          support@deliverydateestimator.app
        </a>
        .
      </p>

      <p>
        <Link to="/">Back to home</Link>
      </p>
    </main>
  );
}
