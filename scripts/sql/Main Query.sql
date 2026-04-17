CREATE TABLE prices_daily (
    ticker VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    [open] FLOAT,
    high FLOAT,
    low FLOAT,
    [close] FLOAT,
    adj_close FLOAT,
    volume BIGINT,

    CONSTRAINT PK_prices_daily PRIMARY KEY (ticker, date)
);

CREATE TABLE fundamentals (
    ticker VARCHAR(10) NOT NULL,
    frequency VARCHAR(20) NOT NULL,
    statement VARCHAR(30) NOT NULL,
    period_end_date DATE NOT NULL,
    line_item VARCHAR(255) NOT NULL,
    value FLOAT,

    CONSTRAINT PK_fundamentals PRIMARY KEY
    (ticker, frequency, statement, period_end_date, line_item)
);

CREATE TABLE company_info (
    ticker VARCHAR(10) NOT NULL,
    short_name VARCHAR(255),
    current_ceo VARCHAR(255),
    sector VARCHAR(100),
    industry VARCHAR(255),
    long_business_summary VARCHAR(MAX),
    address1 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip VARCHAR(20),
    country VARCHAR(100),
    full_time_employees INT,
    current_price FLOAT,
    market_cap FLOAT,
    enterprise_value FLOAT,

    CONSTRAINT PK_company_info PRIMARY KEY (ticker)
);


/*

Created a cleaned version of company business summaries for Power BI dashboard since
the original yfinance summaries are too long.

*/

-- 1. Created a backup

IF OBJECT_ID('company_info_backup_summaries', 'U') IS NULL
BEGIN
    SELECT ticker, long_business_summary
    INTO company_info_backup_summaries
    FROM company_info;
END;


-- 2. Adding new column for cleaned summaries

IF COL_LENGTH('company_info', 'business_summary_clean') IS NULL
BEGIN
    ALTER TABLE company_info
    ADD business_summary_clean NVARCHAR(MAX);
END;

-- 3. Adding data to new value

UPDATE company_info
SET business_summary_clean = 'Apple Inc. designs and sells consumer technology products including the iPhone, Mac, iPad, Apple Watch, AirPods, and related accessories. The company also generates revenue from services such as the App Store, Apple Music, iCloud, Apple TV+, and payment solutions, serving consumers, businesses, education, and government customers worldwide.'
WHERE ticker = 'AAPL';

UPDATE company_info
SET business_summary_clean = 'Microsoft Corporation develops software, cloud services, and technology solutions for consumers and enterprises worldwide. Its business spans productivity tools such as Microsoft 365, cloud infrastructure through Azure, business applications like Dynamics and LinkedIn, and personal computing products including Windows, Xbox, Surface, Bing, and Copilot.'
WHERE ticker = 'MSFT';

UPDATE company_info
SET business_summary_clean = 'Amazon.com, Inc. operates a global e-commerce and technology platform serving consumers, sellers, developers, and enterprises. Its business includes online retail, third-party marketplace services, digital advertising, subscription services such as Prime, consumer devices, media content, and cloud computing through Amazon Web Services (AWS).'
WHERE ticker = 'AMZN';

UPDATE company_info
SET business_summary_clean = 'Alphabet Inc. provides digital advertising, internet search, cloud computing, and software platforms through its Google ecosystem. Its core businesses include Search, YouTube, Android, Chrome, Google Maps, Google Play, and Google Cloud, while also investing in emerging technology ventures through its Other Bets segment.'
WHERE ticker = 'GOOGL';

UPDATE company_info
SET business_summary_clean = 'Meta Platforms, Inc. develops digital platforms and technologies that help people connect, communicate, and share content globally. Its main products include Facebook, Instagram, Messenger, WhatsApp, and Threads, while its Reality Labs segment focuses on virtual reality, augmented reality, wearable devices, and AI-enabled consumer hardware.'
WHERE ticker = 'META';

UPDATE company_info
SET business_summary_clean = 'NVIDIA Corporation designs high-performance computing and graphics technologies used in artificial intelligence, data centers, gaming, professional visualization, and automotive systems. The company is a leading provider of GPUs, accelerated computing platforms, and AI infrastructure solutions for enterprises, developers, cloud providers, and manufacturers worldwide.'
WHERE ticker = 'NVDA';

UPDATE company_info
SET business_summary_clean = 'Tesla, Inc. designs and manufactures electric vehicles, battery storage systems, and solar energy products. In addition to automotive sales, the company provides charging infrastructure, software and self-driving technologies, energy storage solutions such as Powerwall and Megapack, and related services for residential, commercial, and utility customers.'
WHERE ticker = 'TSLA';

/*
Decided to clean the CEO titles since all contain prefixes such as Mr., Mrs., and Ms. 
*/

UPDATE company_info
SET current_ceo = LTRIM(
    REPLACE(
        REPLACE(
            REPLACE(current_ceo, 'Mr. ', ''),
        'Mrs. ', ''),
    'Ms. ', '')
)
WHERE current_ceo LIKE 'Mr.%'
   OR current_ceo LIKE 'Mrs.%'
   OR current_ceo LIKE 'Ms.%';