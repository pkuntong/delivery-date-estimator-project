import type { LoaderFunctionArgs } from "react-router";
import { data } from "react-router";
import { getStoreConfig, incrementDailyMetric } from "../db.server";
import { authenticate, PLAN_PREMIUM, PLAN_PRO } from "../shopify.server";

const DEFAULT_CONFIG = {
  cutoffHour: 14,
  processingDays: 1,
  shippingDaysMin: 3,
  shippingDaysMax: 5,
  excludeWeekends: true,
  timezone: "America/New_York",
  holidays: [] as string[],
  showCountdown: true,
  labelText: "Estimated delivery",
  countdownText: "Order within",
  countdownSuffix: "to get it by",
  abTestEnabled: false,
  abTestSplit: 50,
  labelTextVariantB: "",
  countdownTextVariantB: "",
  countdownSuffixVariantB: "",
  iconStyle: "truck",
  fontSize: 14,
  textColor: "#333333",
  backgroundColor: "#f8f9fa",
  borderColor: "#e2e2e2",
  urgencyColor: "#e63946",
};

type PlanKey = "free" | "pro" | "premium";

const APP_INSTALLATION_PLAN_QUERY = `#graphql
  query DeliveryDateEstimatorCurrentPlan {
    currentAppInstallation {
      activeSubscriptions {
        name
        status
      }
    }
  }
`;

function safeParseHolidays(raw: string | null | undefined) {
  if (!raw) return [] as string[];

  try {
    const parsed = JSON.parse(raw) as unknown;
    return Array.isArray(parsed)
      ? parsed.filter((item): item is string => typeof item === "string")
      : [];
  } catch {
    return [];
  }
}

function getPlanFromSubscriptionName(name: string | undefined): PlanKey {
  if (name === PLAN_PREMIUM) return "premium";
  if (name === PLAN_PRO) return "pro";
  return "free";
}

async function resolvePlan(admin: unknown): Promise<PlanKey> {
  if (!admin || typeof admin !== "object" || !("graphql" in admin)) {
    return "free";
  }

  try {
    const response = await (admin as { graphql: (query: string) => Promise<Response> }).graphql(
      APP_INSTALLATION_PLAN_QUERY,
    );
    const payload = (await response.json()) as {
      data?: {
        currentAppInstallation?: {
          activeSubscriptions?: Array<{ name?: string; status?: string }>;
        } | null;
      };
    };

    const activeSubscriptions = payload.data?.currentAppInstallation?.activeSubscriptions ?? [];
    const active = activeSubscriptions.find(
      (subscription) => subscription.status?.toUpperCase() === "ACTIVE",
    );

    return getPlanFromSubscriptionName(active?.name);
  } catch {
    return "free";
  }
}

function buildPublicConfig(
  config:
    | {
        cutoffHour: number;
        processingDays: number;
        shippingDaysMin: number;
        shippingDaysMax: number;
        excludeWeekends: boolean;
        timezone: string;
        holidays: string;
        showCountdown: boolean;
        labelText: string;
        countdownText: string;
        countdownSuffix: string;
        abTestEnabled: boolean;
        abTestSplit: number;
        labelTextVariantB: string;
        countdownTextVariantB: string;
        countdownSuffixVariantB: string;
        iconStyle: string;
        fontSize: number;
        textColor: string;
        backgroundColor: string;
        borderColor: string;
        urgencyColor: string;
      }
    | null,
  plan: PlanKey,
) {
  if (!config) return DEFAULT_CONFIG;

  const publicConfig = {
    cutoffHour: config.cutoffHour,
    processingDays: config.processingDays,
    shippingDaysMin: config.shippingDaysMin,
    shippingDaysMax: config.shippingDaysMax,
    excludeWeekends: config.excludeWeekends,
    timezone: config.timezone,
    holidays: DEFAULT_CONFIG.holidays,
    showCountdown: config.showCountdown,
    labelText: config.labelText,
    countdownText: config.countdownText,
    countdownSuffix: DEFAULT_CONFIG.countdownSuffix,
    abTestEnabled: DEFAULT_CONFIG.abTestEnabled,
    abTestSplit: DEFAULT_CONFIG.abTestSplit,
    labelTextVariantB: DEFAULT_CONFIG.labelTextVariantB,
    countdownTextVariantB: DEFAULT_CONFIG.countdownTextVariantB,
    countdownSuffixVariantB: DEFAULT_CONFIG.countdownSuffixVariantB,
    iconStyle: DEFAULT_CONFIG.iconStyle,
    fontSize: DEFAULT_CONFIG.fontSize,
    textColor: DEFAULT_CONFIG.textColor,
    backgroundColor: DEFAULT_CONFIG.backgroundColor,
    borderColor: DEFAULT_CONFIG.borderColor,
    urgencyColor: DEFAULT_CONFIG.urgencyColor,
  };

  if (plan !== "free") {
    publicConfig.holidays = safeParseHolidays(config.holidays);
    publicConfig.countdownSuffix = config.countdownSuffix;
    publicConfig.iconStyle = config.iconStyle;
    publicConfig.fontSize = config.fontSize;
    publicConfig.textColor = config.textColor;
    publicConfig.backgroundColor = config.backgroundColor;
    publicConfig.borderColor = config.borderColor;
    publicConfig.urgencyColor = config.urgencyColor;
  }

  if (plan === "premium") {
    publicConfig.abTestEnabled = config.abTestEnabled;
    publicConfig.abTestSplit = config.abTestSplit;
    publicConfig.labelTextVariantB = config.labelTextVariantB;
    publicConfig.countdownTextVariantB = config.countdownTextVariantB;
    publicConfig.countdownSuffixVariantB = config.countdownSuffixVariantB;
  }

  return publicConfig;
}

export async function loader({ request }: LoaderFunctionArgs) {
  const { admin, session } = await authenticate.public.appProxy(request);
  const url = new URL(request.url);
  const shop = session?.shop ?? url.searchParams.get("shop");
  const source = (url.searchParams.get("source") || "app_proxy").toLowerCase();

  if (!shop) {
    return data({ error: "Missing shop parameter" }, { status: 400 });
  }

  const sourceKey = source.replace(/[^a-z0-9_]/g, "") || "unknown";
  await incrementDailyMetric(shop, "api_config_requests");
  await incrementDailyMetric(shop, `api_config_source_${sourceKey}`);

  const plan = await resolvePlan(admin);
  const config = await getStoreConfig(shop);
  const publicConfig = buildPublicConfig(config, plan);

  return data(publicConfig, {
    headers: {
      "Cache-Control": "public, max-age=60",
    },
  });
}
