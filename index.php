<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mini kutty Beedi | மினிக்குட்டி பீடி</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-primary: #070C16;
            --bg-secondary: #0D1527;
            --accent-sky: #00E5FF;
            --accent-green: #00E676;
            --text-main: #FFFFFF;
            --text-muted: #A0AEC0;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-primary);
            color: var(--text-main);
            margin: 0;
            padding: 0;
            overflow-x: hidden;
        }

        /* Header / Navigation */
        header {
            background: rgba(7, 12, 22, 0.8);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(0, 229, 255, 0.1);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            box-sizing: border-box;
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 24px;
        }

        .logo {
            font-size: 22px;
            font-weight: 800;
            background: linear-gradient(90deg, var(--accent-sky), var(--accent-green));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-decoration: none;
            letter-spacing: 0.5px;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 24px;
        }

        .nav-links a {
            color: var(--text-muted);
            text-decoration: none;
            font-weight: 500;
            font-size: 15px;
            transition: color 0.3s;
        }

        .nav-links a:hover {
            color: var(--accent-sky);
        }

        .btn-login {
            background: linear-gradient(90deg, var(--accent-sky) 0%, var(--accent-green) 100%);
            color: #000;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            font-size: 14px;
            letter-spacing: 0.5px;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0, 229, 255, 0.3);
        }

        /* Hero Section */
        .hero {
            position: relative;
            padding: 140px 24px 80px 24px;
            background: linear-gradient(180deg, var(--bg-primary) 0%, var(--bg-secondary) 100%);
            min-height: 80vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .hero-container {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            gap: 48px;
            align-items: center;
        }

        .hero-content h1 {
            font-size: 52px;
            font-weight: 800;
            line-height: 1.15;
            margin: 0 0 16px 0;
            letter-spacing: -1px;
        }

        .hero-content h1 span {
            background: linear-gradient(90deg, var(--accent-sky), var(--accent-green));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .hero-content .subtitle {
            font-size: 20px;
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 30px;
        }

        .hero-image-wrapper {
            position: relative;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 10px 40px rgba(0, 229, 255, 0.15);
            border: 1.5px solid rgba(0, 229, 255, 0.2);
            transition: transform 0.3s;
        }

        .hero-image-wrapper:hover {
            transform: scale(1.02);
        }

        .hero-image-wrapper img {
            width: 100%;
            height: auto;
            display: block;
        }

        /* Features Section */
        .features {
            padding: 80px 24px;
            background: var(--bg-primary);
        }

        .section-title {
            text-align: center;
            font-size: 36px;
            font-weight: 800;
            margin-bottom: 48px;
        }

        .section-title span {
            background: linear-gradient(90deg, var(--accent-sky), var(--accent-green));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .grid-features {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
        }

        .feature-card {
            background: rgba(13, 21, 39, 0.6);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 16px;
            padding: 32px;
            text-align: center;
            transition: transform 0.3s, border-color 0.3s;
        }

        .feature-card:hover {
            transform: translateY(-8px);
            border-color: rgba(0, 229, 255, 0.3);
        }

        .feature-icon {
            font-size: 40px;
            margin-bottom: 20px;
        }

        .feature-card h3 {
            font-size: 20px;
            font-weight: 600;
            margin: 0 0 12px 0;
            color: var(--accent-sky);
        }

        .feature-card p {
            color: var(--text-muted);
            line-height: 1.5;
            margin: 0;
            font-size: 15px;
        }

        /* Contact Details Section */
        .contact {
            padding: 80px 24px;
            background: linear-gradient(180deg, var(--bg-secondary) 0%, var(--bg-primary) 100%);
            text-align: center;
        }

        .contact-box {
            max-width: 600px;
            margin: 0 auto;
            background: rgba(13, 21, 39, 0.8);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(0, 229, 255, 0.2);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0, 229, 255, 0.1);
        }

        .contact-box h2 {
            font-size: 28px;
            margin-top: 0;
        }

        .phone-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: linear-gradient(90deg, var(--accent-sky) 0%, var(--accent-green) 100%);
            color: #000;
            text-decoration: none;
            font-weight: 800;
            font-size: 22px;
            padding: 15px 30px;
            border-radius: 12px;
            margin-top: 20px;
            transition: transform 0.2s;
        }

        .phone-btn:hover {
            transform: scale(1.05);
        }

        /* Footer */
        footer {
            background: #040810;
            padding: 30px 24px;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            text-align: center;
            color: var(--text-muted);
            font-size: 14px;
        }

        @media (max-width: 768px) {
            .hero-container {
                grid-template-columns: 1fr;
                text-align: center;
                gap: 32px;
            }
            .hero-content h1 {
                font-size: 38px;
            }
            .grid-features {
                grid-template-columns: 1fr;
            }
            .nav-links {
                display: none;
            }
        }
    </style>
</head>
<body>

    <!-- Header Navigation -->
    <header>
        <div class="nav-container">
            <a href="#" class="logo">Mini kutty Beedi</a>
            <div class="nav-links">
                <a href="#home">Home</a>
                <a href="#features">Features</a>
                <a href="#contact">Contact</a>
                <a href="login.php" class="btn-login">ADMIN LOGIN</a>
            </div>
        </div>
    </header>

    <!-- Hero Showcase Section -->
    <section class="hero" id="home">
        <div class="hero-container">
            <div class="hero-content">
                <h1>மினிக்குட்டி பீடி <br><span>Mini kutty Beedi</span></h1>
                <div class="subtitle">தலைமுறைகள் கடந்த தரம் மற்றும் நம்பிக்கை. Quality and Trust since generations. Delivering traditional roll taste with handpicked ingredients.</div>
                <a href="login.php" class="btn-login">OPEN ADMIN PANEL</a>
            </div>
            <div class="hero-image-wrapper">
                <img src="uploads/homepage_banner.jpg" alt="Mini kutty Beedi Banner">
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features" id="features">
        <div class="section-title">ஏன் எங்களை <span>தேர்ந்தெடுக்க வேண்டும்?</span></div>
        <div class="grid-features">
            <div class="feature-card">
                <div class="feature-icon">✨</div>
                <h3>Traditional Quality</h3>
                <p>உயர்தர இலைகள் கொண்டு கைமுறையாக தயாரிக்கப்பட்டது. Traditional rolling craftsmanship passed down over generations.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🍃</div>
                <h3>Superior Leaves</h3>
                <p>தேர்ந்தெடுக்கப்பட்ட தரமான டெண்டு இலைகளின் நறுமணம். Handpicked premium quality Tendu leaves wrapper.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🔥</div>
                <h3>Rich Blend</h3>
                <p>நிறைவான மற்றும் இதமான புகை அனுபவம். Richly blended and processed tobacco for absolute satisfaction.</p>
            </div>
        </div>
    </section>

    <!-- Contact details -->
    <section class="contact" id="contact">
        <div class="contact-box">
            <h2>✉️ தொடர்புக்கு / Contact Us</h2>
            <p>உங்களுக்கு ஏதேனும் வணிகத் தேவைகள் அல்லது விவரங்களுக்கு எங்களை மின்னஞ்சல் மூலம் தொடர்பு கொள்ளவும்.</p>
            <a href="mailto:info@minikuttybeedi.com" class="phone-btn">Email: info@minikuttybeedi.com</a>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <p>&copy; 2028 Mini kutty Beedi. All Rights Reserved. Designed for Premium Quality.</p>
    </footer>

</body>
</html>
