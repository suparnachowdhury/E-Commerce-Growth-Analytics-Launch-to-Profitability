-- ============================================================
-- UrbanNest Home Goods — E-Commerce Database Schema
-- Project: E-Commerce Growth Analytics: Launch to Profitability
-- Store Launch Date: 2023-01-07
-- Data Range: 2023-01-07 to 2025-12-31
-- ============================================================
 
 
-- ------------------------------------------------------------
-- TABLE 1: website_sessions
-- One row per website visit. Tracks traffic source details
-- and device type for every session.
-- ------------------------------------------------------------
CREATE TABLE website_sessions (
    website_session_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    created_at            DATETIME        NOT NULL,
    user_id               BIGINT UNSIGNED NOT NULL,
    is_repeat_session     TINYINT(1)      NOT NULL,  -- 0 = new, 1 = returning
    utm_source            VARCHAR(12),               -- g_search | b_search | snapbook | NULL
    utm_campaign          VARCHAR(20),               -- nonbrand | brand | pilot | desktop_targeted | NULL
    utm_content           VARCHAR(30),               -- home_decor_search | urbannest_brand | spring_home_refresh | desktop_home_styling | NULL
    device_type           VARCHAR(15)     NOT NULL,  -- desktop | mobile
    http_referer          VARCHAR(100),              -- referring domain URL
    PRIMARY KEY (website_session_id)
);


-- ------------------------------------------------------------
-- TABLE 2: website_pageviews
-- One row per page viewed. Links to website_sessions
-- via website_session_id.
-- ------------------------------------------------------------
CREATE TABLE website_pageviews (
    website_pageview_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    created_at            DATETIME        NOT NULL,
    website_session_id    BIGINT UNSIGNED NOT NULL,
    pageview_url          VARCHAR(50)     NOT NULL,
    -- Common URLs:
    --   /home
    --   /products
    --   /the-aldgate-picture-frame-set
    --   /the-camden-pillar-candle-set
    --   /the-ashford-ceramic-vase
    --   /the-westbrook-wall-mirror
    --   /cart
    --   /shipping
    --   /billing
    --   /billing-2
    --   /thank-you-for-your-order
    PRIMARY KEY (website_pageview_id)
);

-- ------------------------------------------------------------
-- TABLE 3: orders
-- One row per completed order. Links to website_sessions
-- via website_session_id.
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    created_at            DATETIME        NOT NULL,
    website_session_id    BIGINT UNSIGNED NOT NULL,
    user_id               BIGINT UNSIGNED NOT NULL,
    primary_product_id    SMALLINT UNSIGNED NOT NULL,  -- FK to products.product_id
    items_purchased       SMALLINT UNSIGNED NOT NULL,
    price_usd             DECIMAL(6,2)    NOT NULL,
    cogs_usd              DECIMAL(6,2)    NOT NULL,    -- cost of goods sold
    PRIMARY KEY (order_id)
);
