-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateTable
CREATE TABLE "Session" (
    "id" TEXT NOT NULL,
    "shop" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "isOnline" BOOLEAN NOT NULL DEFAULT false,
    "scope" TEXT,
    "expires" TIMESTAMP(3),
    "accessToken" TEXT NOT NULL,
    "userId" BIGINT,
    "firstName" TEXT,
    "lastName" TEXT,
    "email" TEXT,
    "accountOwner" BOOLEAN NOT NULL DEFAULT false,
    "locale" TEXT,
    "collaborator" BOOLEAN DEFAULT false,
    "emailVerified" BOOLEAN DEFAULT false,
    "refreshToken" TEXT,
    "refreshTokenExpires" TIMESTAMP(3),

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StoreConfig" (
    "id" TEXT NOT NULL,
    "shop" TEXT NOT NULL,
    "cutoffHour" INTEGER NOT NULL DEFAULT 14,
    "processingDays" INTEGER NOT NULL DEFAULT 1,
    "shippingDaysMin" INTEGER NOT NULL DEFAULT 3,
    "shippingDaysMax" INTEGER NOT NULL DEFAULT 5,
    "excludeWeekends" BOOLEAN NOT NULL DEFAULT true,
    "timezone" TEXT NOT NULL DEFAULT 'America/New_York',
    "holidays" TEXT NOT NULL DEFAULT '',
    "showCountdown" BOOLEAN NOT NULL DEFAULT true,
    "labelText" TEXT NOT NULL DEFAULT 'Estimated delivery',
    "countdownText" TEXT NOT NULL DEFAULT 'Order within',
    "countdownSuffix" TEXT NOT NULL DEFAULT 'to get it by',
    "abTestEnabled" BOOLEAN NOT NULL DEFAULT false,
    "abTestSplit" INTEGER NOT NULL DEFAULT 50,
    "labelTextVariantB" TEXT NOT NULL DEFAULT '',
    "countdownTextVariantB" TEXT NOT NULL DEFAULT '',
    "countdownSuffixVariantB" TEXT NOT NULL DEFAULT '',
    "iconStyle" TEXT NOT NULL DEFAULT 'truck',
    "fontSize" INTEGER NOT NULL DEFAULT 14,
    "textColor" TEXT NOT NULL DEFAULT '#333333',
    "backgroundColor" TEXT NOT NULL DEFAULT '#f8f9fa',
    "borderColor" TEXT NOT NULL DEFAULT '#e2e2e2',
    "urgencyColor" TEXT NOT NULL DEFAULT '#e63946',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "sessionId" TEXT,

    CONSTRAINT "StoreConfig_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OnboardingProgress" (
    "id" TEXT NOT NULL,
    "shop" TEXT NOT NULL,
    "themeBlockAdded" BOOLEAN NOT NULL DEFAULT false,
    "shippingConfigured" BOOLEAN NOT NULL DEFAULT false,
    "holidaysValidated" BOOLEAN NOT NULL DEFAULT false,
    "mobileVerified" BOOLEAN NOT NULL DEFAULT false,
    "billingLive" BOOLEAN NOT NULL DEFAULT false,
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OnboardingProgress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AnalyticsEvent" (
    "id" TEXT NOT NULL,
    "shop" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "properties" TEXT NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AnalyticsEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DailyMetric" (
    "id" TEXT NOT NULL,
    "shop" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "count" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DailyMetric_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "StoreConfig_shop_key" ON "StoreConfig"("shop");

-- CreateIndex
CREATE UNIQUE INDEX "StoreConfig_sessionId_key" ON "StoreConfig"("sessionId");

-- CreateIndex
CREATE UNIQUE INDEX "OnboardingProgress_shop_key" ON "OnboardingProgress"("shop");

-- CreateIndex
CREATE INDEX "AnalyticsEvent_shop_createdAt_idx" ON "AnalyticsEvent"("shop", "createdAt");

-- CreateIndex
CREATE INDEX "AnalyticsEvent_shop_name_createdAt_idx" ON "AnalyticsEvent"("shop", "name", "createdAt");

-- CreateIndex
CREATE INDEX "DailyMetric_shop_date_idx" ON "DailyMetric"("shop", "date");

-- CreateIndex
CREATE INDEX "DailyMetric_shop_key_date_idx" ON "DailyMetric"("shop", "key", "date");

-- CreateIndex
CREATE UNIQUE INDEX "DailyMetric_shop_key_date_key" ON "DailyMetric"("shop", "key", "date");

-- AddForeignKey
ALTER TABLE "StoreConfig" ADD CONSTRAINT "StoreConfig_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("id") ON DELETE SET NULL ON UPDATE CASCADE;

