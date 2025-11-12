<script>
  import { onMount } from 'svelte';
  import { Button } from '$lib/components/ui/button';
  import * as Card from '$lib/components/ui/card';

  console.log('Home component loaded');

  onMount(() => {
    console.log('Home component mounted');

    // Initialize Lucide icons after a short delay to ensure they're loaded
    const initIcons = () => {
      if (typeof lucide !== 'undefined' && lucide.createIcons) {
        try {
          lucide.createIcons();
          console.log('Lucide icons initialized');
        } catch (error) {
          console.error('Error initializing Lucide icons:', error);
        }
      }
    };

    // Try to initialize icons with a small delay
    setTimeout(initIcons, 100);
  });
</script>

<svelte:head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MonacoGDPR - Conformité RGPD Simplifiée pour les Entreprises Monégasques</title>

  <!-- Open Graph Meta Tags -->
  <meta property="og:title" content="MonacoGDPR - Conformité RGPD en 30 jours pour les PME monégasques">
  <meta property="og:description" content="Obtenez votre conformité RGPD complète en 30 jours avec l'expertise d'un DPO qualifié, à 70% moins cher qu'un cabinet traditionnel. Plateforme SaaS conçue pour la loi monégasque n° 1.565.">
  <meta property="og:image" content="https://monacogdpr.mc/og-image.jpg">
  <meta property="og:url" content="https://monacogdpr.mc">
  <meta property="og:type" content="website">
  <meta property="og:locale" content="fr_FR">

  <!-- Twitter Card Meta Tags -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="MonacoGDPR - Conformité RGPD en 30 jours">
  <meta name="twitter:description" content="Conformité RGPD automatisée + DPO expert pour les entreprises monégasques. 70% moins cher qu'un cabinet traditionnel.">
  <meta name="twitter:image" content="https://monacogdpr.mc/og-image.jpg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <script src="https://unpkg.com/lucide@latest"></script>
</svelte:head>

<style>
/* Reset & Base Styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:global(html) {
    scroll-behavior: smooth;
}

:root {
    /* Colors */
    --primary: #2563eb;
    --primary-dark: #1e40af;
    --primary-light: #3b82f6;
    --secondary: #10b981;
    --accent: #f59e0b;
    --dark: #0f172a;
    --dark-light: #1e293b;
    --gray: #64748b;
    --gray-light: #e2e8f0;
    --gray-lighter: #f1f5f9;
    --white: #ffffff;
    --red: #ef4444;
    --red-light: #fee2e2;

    /* Spacing */
    --container-width: 1200px;
    --section-padding: 80px 0;

    /* Shadows */
    --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
    --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
    --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1);

    /* Border Radius */
    --radius-sm: 6px;
    --radius-md: 12px;
    --radius-lg: 16px;
    --radius-xl: 24px;
}

:global(body) {
    line-height: 1.6;
    color: var(--dark);
    background: var(--white);
    overflow-x: hidden;
}

:global(h1), :global(h2), :global(h3), :global(h4), :global(h5), :global(h6) {
    font-weight: 700;
}

.container {
    max-width: var(--container-width);
    margin: 0 auto;
    padding: 0 24px;
}

/* Header & Navigation */
.header {
    position: sticky;
    top: 0;
    z-index: 1000;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-bottom: 1px solid var(--gray-light);
    padding: 16px 0;
}

.nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 24px;
    font-weight: 700;
    color: var(--dark);
    text-decoration: none;
    transition: opacity 0.3s;
}

.logo:hover {
    opacity: 0.8;
}

.logo-icon {
    width: 28px;
    height: 28px;
    color: var(--primary);
}

.nav-links {
    display: flex;
    gap: 32px;
    list-style: none;
    align-items: center;
}

.nav-links a {
    text-decoration: none;
    color: var(--gray);
    font-weight: 500;
    transition: color 0.3s;
}

.nav-links a:hover {
    color: var(--primary);
}

/* Buttons */
.btn-primary, .btn-secondary, .btn-outline, .btn-card {
    display: inline-block;
    padding: 12px 24px;
    border-radius: var(--radius-md);
    font-weight: 600;
    text-decoration: none;
    transition: all 0.3s;
    text-align: center;
    cursor: pointer;
    border: 2px solid transparent;
}

.btn-primary {
    background: var(--primary);
    color: var(--white);
}

.btn-primary:hover {
    background: var(--primary-dark);
    transform: translateY(-2px);
    box-shadow: var(--shadow-lg);
}

.btn-secondary {
    background: var(--white);
    color: var(--primary);
    border: 2px solid var(--primary);
}

.btn-secondary:hover {
    background: var(--primary);
    color: var(--white);
}

.btn-outline {
    background: transparent;
    color: var(--dark);
    border: 2px solid var(--gray-light);
}

.btn-outline:hover {
    border-color: var(--primary);
    color: var(--primary);
}

.btn-large {
    padding: 16px 32px;
    font-size: 18px;
}

.btn-card {
    width: 100%;
    background: var(--white);
    color: var(--primary);
    border: 2px solid var(--primary);
}

.btn-card:hover {
    background: var(--primary);
    color: var(--white);
}

.btn-card-primary {
    background: var(--primary);
    color: var(--white);
}

.btn-card-primary:hover {
    background: var(--primary-dark);
}

/* Hero Section */
.hero {
    padding: 80px 0 120px;
    background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
    position: relative;
    overflow: hidden;
}

.hero::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -10%;
    width: 600px;
    height: 600px;
    background: radial-gradient(circle, rgba(37, 99, 235, 0.1) 0%, transparent 70%);
    border-radius: 50%;
}

.hero-content {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 60px;
    align-items: center;
}

.hero-text {
    z-index: 1;
}

.hero h1 {
    font-size: 56px;
    font-weight: 800;
    line-height: 1.1;
    margin-bottom: 24px;
    color: var(--dark);
}

.highlight {
    color: var(--primary);
    position: relative;
}

.hero-description {
    font-size: 20px;
    color: var(--gray);
    margin-bottom: 32px;
    line-height: 1.8;
}

.hero-cta {
    display: flex;
    gap: 16px;
    margin-bottom: 32px;
}

.trust-indicators {
    display: flex;
    gap: 24px;
    flex-wrap: wrap;
}

.trust-item {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--gray);
    font-size: 14px;
    font-weight: 500;
}

.trust-icon {
    width: 20px;
    height: 20px;
    color: var(--secondary);
}

/* Dashboard Preview */
.hero-visual {
    display: flex;
    justify-content: center;
    align-items: center;
}

.dashboard-preview {
    position: relative;
    z-index: 1;
    animation: fadeInUp 0.8s ease-out;
}

@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.preview-card {
    background: var(--white);
    border-radius: var(--radius-xl);
    padding: 32px;
    box-shadow: var(--shadow-xl);
    border: 1px solid var(--gray-light);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.preview-card:hover {
    transform: translateY(-8px);
    box-shadow: 0 30px 40px -10px rgba(0, 0, 0, 0.15);
}

.card-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 24px;
    font-weight: 600;
    color: var(--dark);
}

.status-dot {
    width: 12px;
    height: 12px;
    border-radius: 50%;
}

.status-success {
    background: var(--secondary);
    box-shadow: 0 0 8px var(--secondary);
    animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% {
        opacity: 1;
        transform: scale(1);
    }
    50% {
        opacity: 0.7;
        transform: scale(1.1);
    }
}

.progress-ring {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 24px 0;
}

.progress-ring svg {
    transform: rotate(-90deg);
}

.progress-bg {
    fill: none;
    stroke: var(--gray-light);
    stroke-width: 8;
}

.progress-fill {
    fill: none;
    stroke: var(--primary);
    stroke-width: 8;
    stroke-linecap: round;
    stroke-dasharray: 440;
    stroke-dashoffset: 110;
    transition: stroke-dashoffset 1s ease;
    animation: progressGlow 3s ease-in-out infinite;
}

@keyframes progressGlow {
    0%, 100% {
        filter: drop-shadow(0 0 4px var(--primary));
    }
    50% {
        filter: drop-shadow(0 0 8px var(--primary));
    }
}

.progress-text {
    position: absolute;
    display: flex;
    flex-direction: column;
    align-items: center;
}

.progress-value {
    font-size: 36px;
    font-weight: 800;
    color: var(--primary);
    animation: countUp 2s ease-out;
}

@keyframes countUp {
    from {
        opacity: 0;
        transform: scale(0.5);
    }
    to {
        opacity: 1;
        transform: scale(1);
    }
}

.progress-label {
    font-size: 14px;
    color: var(--gray);
}

.metrics {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    margin-top: 24px;
}

.metric {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 12px;
    background: var(--gray-lighter);
    border-radius: var(--radius-md);
    transition: all 0.3s ease;
    animation: slideIn 0.6s ease-out backwards;
}

.metric:nth-child(1) {
    animation-delay: 0.2s;
}

.metric:nth-child(2) {
    animation-delay: 0.4s;
}

.metric:nth-child(3) {
    animation-delay: 0.6s;
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.metric:hover {
    background: var(--primary-light);
    transform: scale(1.05);
}

.metric:hover .metric-value {
    color: var(--white);
}

.metric:hover .metric-label {
    color: rgba(255, 255, 255, 0.9);
}

.metric-value {
    font-size: 24px;
    font-weight: 700;
    color: var(--dark);
    transition: color 0.3s ease;
}

.metric-label {
    font-size: 12px;
    color: var(--gray);
    text-align: center;
    transition: color 0.3s ease;
}

/* Section Styles */
section {
    padding: var(--section-padding);
}

.section-header {
    text-align: center;
    max-width: 800px;
    margin: 0 auto 60px;
}

.section-tag {
    display: inline-block;
    color: var(--primary);
    font-weight: 600;
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 16px;
}

.section-header h2 {
    font-size: 42px;
    font-weight: 800;
    margin-bottom: 16px;
    color: var(--dark);
}

.section-description {
    font-size: 18px;
    color: var(--gray);
}

/* Problem Section */
.problem {
    background: var(--white);
}

.problem-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 32px;
}

.problem-card {
    padding: 32px;
    background: var(--red-light);
    border-radius: var(--radius-lg);
    border: 2px solid #fecaca;
}

.problem-icon {
    width: 48px;
    height: 48px;
    display: block;
    margin-bottom: 16px;
    color: var(--red);
}

.problem-card h3 {
    font-size: 22px;
    margin-bottom: 12px;
    color: var(--dark);
}

.problem-card p {
    color: var(--gray);
    line-height: 1.6;
}

/* Solution Section */
.solution {
    background: var(--gray-lighter);
}

.solution-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
    gap: 32px;
}

.solution-card {
    background: var(--white);
    padding: 40px;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-md);
    transition: transform 0.3s, box-shadow 0.3s;
}

.solution-card:hover {
    transform: translateY(-8px);
    box-shadow: var(--shadow-xl);
}

.solution-icon {
    width: 56px;
    height: 56px;
    display: block;
    margin-bottom: 24px;
    color: var(--primary);
}

.solution-card h3 {
    font-size: 24px;
    margin-bottom: 16px;
    color: var(--dark);
}

.solution-card > p {
    color: var(--gray);
    margin-bottom: 24px;
    font-size: 16px;
}

.feature-list {
    list-style: none;
    margin-top: 24px;
}

.feature-list li {
    padding: 8px 0;
    padding-left: 28px;
    position: relative;
    color: var(--gray);
}

.feature-list li::before {
    content: '✓';
    position: absolute;
    left: 0;
    color: var(--secondary);
    font-weight: bold;
}

/* Features Section */
.features {
    background: var(--white);
}

.features-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 24px;
}

.feature-card {
    background: var(--white);
    padding: 32px;
    border-radius: var(--radius-lg);
    border: 2px solid var(--gray-light);
    transition: border-color 0.3s, transform 0.3s;
}

.feature-card:hover {
    border-color: var(--primary);
    transform: translateY(-4px);
}

.feature-header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 16px;
}

.feature-icon {
    width: 32px;
    height: 32px;
    color: var(--primary);
    flex-shrink: 0;
}

.feature-card h3 {
    font-size: 20px;
    color: var(--dark);
}

.feature-card p {
    color: var(--gray);
    margin-bottom: 16px;
    line-height: 1.6;
}

.feature-badge {
    display: inline-block;
    background: var(--primary);
    color: var(--white);
    padding: 4px 12px;
    border-radius: 50px;
    font-size: 12px;
    font-weight: 600;
}

/* How It Works */
.how-it-works {
    background: var(--gray-lighter);
}

.steps {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 32px;
    max-width: 1000px;
    margin: 0 auto;
}

.step {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
}

.step-number {
    width: 80px;
    height: 80px;
    background: var(--primary);
    color: var(--white);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 36px;
    font-weight: 800;
    margin-bottom: 24px;
    box-shadow: var(--shadow-lg);
}

.step-content h3 {
    font-size: 24px;
    margin-bottom: 12px;
    color: var(--dark);
}

.step-content p {
    color: var(--gray);
    line-height: 1.6;
    margin-bottom: 16px;
}

.step-duration {
    display: inline-block;
    background: var(--secondary);
    color: var(--white);
    padding: 6px 16px;
    border-radius: 50px;
    font-size: 14px;
    font-weight: 600;
}

.step-arrow {
    font-size: 32px;
    color: var(--primary);
    font-weight: bold;
}

/* Pricing Section */
.pricing {
    background: var(--white);
}

.pricing-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
    gap: 32px;
    margin-bottom: 40px;
}

.pricing-card {
    background: var(--white);
    border: 2px solid var(--gray-light);
    border-radius: var(--radius-lg);
    padding: 40px;
    transition: transform 0.3s, box-shadow 0.3s, border-color 0.3s;
    position: relative;
}

.pricing-card:hover {
    transform: translateY(-8px);
    box-shadow: var(--shadow-xl);
    border-color: var(--primary);
}

.pricing-card.featured {
    border-color: var(--primary);
    border-width: 3px;
    box-shadow: var(--shadow-lg);
}

.popular-badge {
    position: absolute;
    top: -16px;
    left: 50%;
    transform: translateX(-50%);
    background: var(--accent);
    color: var(--white);
    padding: 8px 24px;
    border-radius: 50px;
    font-size: 14px;
    font-weight: 700;
}

.pricing-header h3 {
    font-size: 28px;
    margin-bottom: 8px;
    color: var(--dark);
}

.pricing-header p {
    color: var(--gray);
    margin-bottom: 24px;
}

.pricing-price {
    margin-bottom: 32px;
}

.price {
    font-size: 56px;
    font-weight: 800;
    color: var(--primary);
}

.period {
    font-size: 18px;
    color: var(--gray);
}

.pricing-features {
    list-style: none;
    margin-bottom: 32px;
}

.pricing-features li {
    padding: 12px 0;
    display: flex;
    align-items: center;
    gap: 12px;
    color: var(--gray);
}

.check {
    width: 20px;
    height: 20px;
    color: var(--secondary);
    flex-shrink: 0;
}

.pricing-footer {
    text-align: center;
    padding: 32px;
    background: var(--gray-lighter);
    border-radius: var(--radius-lg);
}

.pricing-footer p {
    color: var(--gray);
    font-size: 16px;
}

/* Monaco Made Section */
.monaco-made {
    background: linear-gradient(135deg, #ce1126 0%, #a00d1e 100%);
    color: var(--white);
}

.monaco-made-content {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 64px;
    align-items: center;
}

.monaco-made-text h2 {
    font-size: 42px;
    margin-bottom: 24px;
    color: var(--white);
}

.monaco-made-text p {
    font-size: 18px;
    line-height: 1.8;
    margin-bottom: 32px;
    color: rgba(255, 255, 255, 0.9);
}

.monaco-features {
    list-style: none;
    display: grid;
    gap: 16px;
}

.monaco-features li {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 18px;
    color: var(--white);
}

.monaco-features .check {
    width: 24px;
    height: 24px;
    color: rgba(255, 255, 255, 0.9);
}

.monaco-made-logo {
    text-align: center;
    background: rgba(255, 255, 255, 0.1);
    padding: 48px;
    border-radius: var(--radius-xl);
    backdrop-filter: blur(10px);
}

.monaco-logo {
    width: 100%;
    max-width: 300px;
    height: auto;
    margin-bottom: 24px;
    filter: brightness(0) invert(1);
}

.monaco-badge {
    font-size: 18px;
    font-weight: 600;
    color: var(--white);
    margin: 0;
}

@media (max-width: 968px) {
    .monaco-made-content {
        grid-template-columns: 1fr;
        gap: 48px;
    }

    .monaco-made-text h2 {
        font-size: 32px;
    }

    .monaco-logo {
        max-width: 240px;
    }
}

/* Trust Section */
.trust {
    background: var(--gray-lighter);
}

.trust-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: 32px;
}

.trust-card {
    background: var(--white);
    padding: 40px;
    border-radius: var(--radius-lg);
    text-align: center;
    box-shadow: var(--shadow-md);
}

.trust-icon-large {
    width: 64px;
    height: 64px;
    display: block;
    margin: 0 auto 24px;
    color: var(--primary);
}

.trust-card h3 {
    font-size: 22px;
    margin-bottom: 16px;
    color: var(--dark);
}

.trust-card p {
    color: var(--gray);
    line-height: 1.6;
}

/* CTA Section */
.cta {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: var(--white);
    text-align: center;
    padding: 100px 0;
}

.cta-content h2 {
    font-size: 48px;
    font-weight: 800;
    margin-bottom: 16px;
}

.cta-content > p {
    font-size: 20px;
    margin-bottom: 40px;
    opacity: 0.9;
}

.cta-buttons {
    display: flex;
    justify-content: center;
    gap: 16px;
    margin-bottom: 24px;
    flex-wrap: wrap;
}

.cta .btn-primary {
    background: var(--white);
    color: var(--primary);
}

.cta .btn-primary:hover {
    background: var(--gray-lighter);
}

.cta .btn-outline {
    border-color: var(--white);
    color: var(--white);
}

.cta .btn-outline:hover {
    background: var(--white);
    color: var(--primary);
}

.cta-note {
    font-size: 14px;
    opacity: 0.8;
}

/* Footer */
.footer {
    background: var(--dark);
    color: var(--gray-light);
    padding: 60px 0 20px;
}

.footer-grid {
    display: grid;
    grid-template-columns: 2fr 1fr 1fr 1fr;
    gap: 40px;
    margin-bottom: 40px;
}

.footer-logo {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 24px;
    font-weight: 700;
    color: var(--white);
    margin-bottom: 16px;
    text-decoration: none;
    transition: opacity 0.3s;
}

.footer-logo:hover {
    opacity: 0.8;
}

.footer-col p {
    line-height: 1.8;
    margin-bottom: 16px;
}

.footer-col h4 {
    color: var(--white);
    margin-bottom: 16px;
    font-size: 18px;
}

.footer-col ul {
    list-style: none;
}

.footer-col ul li {
    margin-bottom: 12px;
}

.footer-col ul li a {
    color: var(--gray-light);
    text-decoration: none;
    transition: color 0.3s;
}

.footer-col ul li a:hover {
    color: var(--primary-light);
}

.footer-bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 20px;
    border-top: 1px solid var(--dark-light);
}

.footer-links {
    display: flex;
    gap: 24px;
}

.footer-links a {
    color: var(--gray-light);
    text-decoration: none;
    font-size: 14px;
    transition: color 0.3s;
}

.footer-links a:hover {
    color: var(--primary-light);
}

/* Responsive Design */
@media (max-width: 968px) {
    .hero-content {
        grid-template-columns: 1fr;
        text-align: center;
    }

    .hero h1 {
        font-size: 42px;
    }

    .hero-cta {
        justify-content: center;
    }

    .trust-indicators {
        justify-content: center;
    }

    .hero-visual {
        order: -1;
    }

    .steps {
        flex-direction: column;
    }

    .step-arrow {
        transform: rotate(90deg);
    }

    .footer-grid {
        grid-template-columns: 1fr 1fr;
    }
}

@media (max-width: 640px) {
    .nav-links {
        gap: 16px;
        font-size: 14px;
    }

    .hero h1 {
        font-size: 32px;
    }

    .hero-description {
        font-size: 16px;
    }

    .hero-cta {
        flex-direction: column;
    }

    .section-header h2 {
        font-size: 32px;
    }

    .cta-content h2 {
        font-size: 32px;
    }

    .cta-buttons {
        flex-direction: column;
    }

    .footer-grid {
        grid-template-columns: 1fr;
    }

    .footer-bottom {
        flex-direction: column;
        gap: 16px;
    }
}
</style>

<!-- Header -->
    <header class="header">
        <nav class="nav container">
            <a href="/mcrgpd" class="logo">
                <i data-lucide="shield-check" class="logo-icon"></i>
                <span class="logo-text"><span style="color: red;">Monaco</span>RGPD</span>
            </a>
            <ul class="nav-links">
                <li><a href="#fonctionnalites">Fonctionnalités</a></li>
                <li><a href="#tarifs">Tarifs</a></li>
                <li><a href="#apropos">À Propos</a></li>
                <li><a href="#contact" class="btn-secondary">Démo Gratuite</a></li>
            </ul>
        </nav>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container">
            <div class="hero-content">
                <div class="hero-text">
                    <h1>Conformité RGPD monégasque en <span class="highlight">30 jours</span>, pas 6 mois.</h1>
                    <p class="hero-description">
                        La première plateforme logicielle conçue spécifiquement pour les entreprises monégasques.
                        Obtenez votre conformité RGPD complète avec l'expertise d'un DPO qualifié,
                        à <strong>70% moins cher</strong> qu'un cabinet traditionnel.
                        Réduisez de <strong>90%</strong> votre charge de travail administratif.
                    </p>
                    <div class="hero-cta">
                        <a href="#contact" class="btn-primary">Évaluation Gratuite</a>
                        <a href="#fonctionnalites" class="btn-outline">Découvrir la plateforme</a>
                    </div>
                    <div class="trust-indicators">
                        <div class="trust-item">
                            <i data-lucide="check-circle" class="trust-icon"></i>
                            <span>Conforme APDP</span>
                        </div>
                        <div class="trust-item">
                            <i data-lucide="check-circle" class="trust-icon"></i>
                            <span>DPO Expert Monaco</span>
                        </div>
                        <div class="trust-item">
                            <i data-lucide="check-circle" class="trust-icon"></i>
                            <span>Convention 108+</span>
                        </div>
                    </div>
                </div>
                <div class="hero-visual">
                    <div class="dashboard-preview">
                        <div class="preview-card">
                            <div class="card-header">
                                <span class="status-dot status-success"></span>
                                <span>Tableau de Bord Conformité</span>
                            </div>
                            <div class="progress-ring">
                                <svg width="180" height="180">
                                    <circle cx="90" cy="90" r="70" class="progress-bg"></circle>
                                    <circle cx="90" cy="90" r="70" class="progress-fill" style="stroke-dashoffset: 110;"></circle>
                                </svg>
                                <div class="progress-text">
                                    <span class="progress-value">75%</span>
                                    <span class="progress-label">Conforme</span>
                                </div>
                            </div>
                            <div class="metrics">
                                <div class="metric">
                                    <span class="metric-value">8/8</span>
                                    <span class="metric-label">Droits Individuels</span>
                                </div>
                                <div class="metric">
                                    <span class="metric-value">12</span>
                                    <span class="metric-label">Traitements</span>
                                </div>
                                <div class="metric">
                                    <span class="metric-value">0</span>
                                    <span class="metric-label">Incident</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Problem Section -->
    <section class="problem">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Le Défi</span>
                <h2>La conformité RGPD est complexe et coûteuse</h2>
            </div>
            <div class="problem-grid">
                <div class="problem-card">
                    <i data-lucide="clock" class="problem-icon"></i>
                    <h3>Chronophage</h3>
                    <p>6+ mois pour une mise en conformité manuelle avec des cabinets traditionnels</p>
                </div>
                <div class="problem-card">
                    <i data-lucide="banknote" class="problem-icon"></i>
                    <h3>Trop Cher</h3>
                    <p>€15K-50K+ en honoraires de consulting DPO externe pour les PME</p>
                </div>
                <div class="problem-card">
                    <i data-lucide="book-open" class="problem-icon"></i>
                    <h3>Complexe</h3>
                    <p>Loi n° 1.565 avec 8 droits individuels, registres obligatoires, notification APDP...</p>
                </div>
                <div class="problem-card">
                    <i data-lucide="alert-triangle" class="problem-icon"></i>
                    <h3>Risqué</h3>
                    <p>Non-conformité = amendes importantes + atteinte à la réputation</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Solution Section -->
    <section class="solution">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">La Solution MonacoGDPR</span>
                <h2>Conformité automatisée + Expertise DPO</h2>
                <p class="section-description">Une plateforme intelligente qui guide votre entreprise étape par étape vers la conformité totale</p>
            </div>
            <div class="solution-grid">
                <div class="solution-card">
                    <i data-lucide="zap" class="solution-icon"></i>
                    <h3>30 Jours pour la Conformité</h3>
                    <p>Notre processus structuré en 3 phases vous rend conforme en 1 mois au lieu de 6+</p>
                    <ul class="feature-list">
                        <li>Évaluation complète en 13 sections</li>
                        <li>Plan d'action automatique personnalisé</li>
                        <li>Suivi en temps réel de votre progression</li>
                    </ul>
                </div>
                <div class="solution-card">
                    <i data-lucide="gem" class="solution-icon"></i>
                    <h3>70% Moins Cher</h3>
                    <p>À partir de €199/mois vs €15K+ en consulting traditionnel</p>
                    <ul class="feature-list">
                        <li>SaaS tout-en-un sans frais cachés</li>
                        <li>Modèle hybride : plateforme + expert</li>
                        <li>ROI immédiat dès le premier mois</li>
                    </ul>
                </div>
                <div class="solution-card">
                    <i data-lucide="target" class="solution-icon"></i>
                    <h3>100% Monaco</h3>
                    <p>Conçu exclusivement pour la loi monégasque n° 1.565</p>
                    <ul class="feature-list">
                        <li>Articles de loi référencés directement</li>
                        <li>Intégration directe avec l'APDP</li>
                        <li>Templates officiels Monaco inclus</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="fonctionnalites" class="features">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Fonctionnalités</span>
                <h2>Tout ce dont vous avez besoin pour être conforme</h2>
            </div>
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-header">
                        <i data-lucide="clipboard-list" class="feature-icon"></i>
                        <h3>Portail Droits Individuels</h3>
                    </div>
                    <p>Gestion complète des 8 droits (accès, rectification, effacement, limitation, opposition, portabilité, décisions automatisées, personnes décédées)</p>
                    <span class="feature-badge">Articles 12-20</span>
                </div>

                <div class="feature-card">
                    <div class="feature-header">
                        <i data-lucide="check-square" class="feature-icon"></i>
                        <h3>Gestion du Consentement</h3>
                    </div>
                    <p>Validation 4 piliers (libre, spécifique, éclairé, univoque) avec preuve documentée et retrait facile</p>
                    <span class="feature-badge">Article 6</span>
                </div>

                <div class="feature-card">
                    <div class="feature-header">
                        <i data-lucide="database" class="feature-icon"></i>
                        <h3>Registre des Traitements</h3>
                    </div>
                    <p>Obligatoire pour 50+ employés. Cartographie complète des données, finalités et bases légales</p>
                    <span class="feature-badge">Article 27</span>
                </div>

                <div class="feature-card">
                    <div class="feature-header">
                        <i data-lucide="alert-octagon" class="feature-icon"></i>
                        <h3>Gestion des Incidents</h3>
                    </div>
                    <p>Notification APDP en 72h, classification automatique, communication aux personnes concernées</p>
                    <span class="feature-badge">Notification APDP</span>
                </div>

                <div class="feature-card">
                    <div class="feature-header">
                        <i data-lucide="handshake" class="feature-icon"></i>
                        <h3>Gestion Sous-traitants</h3>
                    </div>
                    <p>Évaluation des risques, contrats DPA, suivi de conformité des processeurs de données</p>
                    <span class="feature-badge">Article 28</span>
                </div>

                <div class="feature-card">
                    <div class="feature-header">
                        <i data-lucide="camera" class="feature-icon"></i>
                        <h3>Vidéosurveillance</h3>
                    </div>
                    <p>Conformité workplace : zones autorisées, rétention 30 jours, finalité sécurité uniquement</p>
                    <span class="feature-badge">Monaco Workplace</span>
                </div>

                <div class="feature-card">
                    <div class="feature-header">
                        <i data-lucide="search" class="feature-icon"></i>
                        <h3>Analyse d'Impact (DPIA)</h3>
                    </div>
                    <p>Déclencheurs automatiques, workflows d'évaluation, mesures d'atténuation des risques</p>
                    <span class="feature-badge">Traitement à Haut Risque</span>
                </div>

                <div class="feature-card">
                    <div class="feature-header">
                        <i data-lucide="bar-chart-3" class="feature-icon"></i>
                        <h3>Tableau de Bord</h3>
                    </div>
                    <p>Score de conformité en temps réel, actions prioritaires, rapports d'audit exportables</p>
                    <span class="feature-badge">Suivi Continu</span>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works -->
    <section class="how-it-works">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Comment Ça Marche</span>
                <h2>Votre parcours vers la conformité en 3 étapes</h2>
            </div>
            <div class="steps">
                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-content">
                        <h3>Évaluation Initiale</h3>
                        <p>Questionnaire complet de 13 sections pour identifier vos traitements et vos besoins spécifiques. Durée : 30 minutes.</p>
                        <span class="step-duration">Jour 1</span>
                    </div>
                </div>
                <div class="step-arrow">→</div>
                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-content">
                        <h3>Plan d'Action Personnalisé</h3>
                        <p>Analyse automatique des écarts et génération d'un plan d'action priorisé avec templates Monaco inclus.</p>
                        <span class="step-duration">Jours 2-7</span>
                    </div>
                </div>
                <div class="step-arrow">→</div>
                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-content">
                        <h3>Mise en Conformité</h3>
                        <p>Suivi guidé avec revue DPO expert. Support continu pour maintenir votre conformité dans le temps.</p>
                        <span class="step-duration">Jours 8-30</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Pricing Section -->
    <section id="tarifs" class="pricing">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Tarifs Transparents</span>
                <h2>Choisissez le plan adapté à votre entreprise</h2>
                <p class="section-description">Sans engagement. Annulation à tout moment.</p>
            </div>
            <div class="pricing-grid">
                <div class="pricing-card">
                    <div class="pricing-header">
                        <h3>Basique</h3>
                        <p>Pour les petites entreprises</p>
                    </div>
                    <div class="pricing-price">
                        <span class="price">€199</span>
                        <span class="period">/mois</span>
                    </div>
                    <ul class="pricing-features">
                        <li><i data-lucide="check" class="check"></i> 1-25 employés</li>
                        <li><i data-lucide="check" class="check"></i> Portail droits individuels</li>
                        <li><i data-lucide="check" class="check"></i> Gestion consentement</li>
                        <li><i data-lucide="check" class="check"></i> Registre traitements</li>
                        <li><i data-lucide="check" class="check"></i> Templates Monaco</li>
                        <li><i data-lucide="check" class="check"></i> Support email</li>
                    </ul>
                    <a href="#contact" class="btn-card">Commencer</a>
                </div>

                <div class="pricing-card featured">
                    <div class="popular-badge">Le Plus Populaire</div>
                    <div class="pricing-header">
                        <h3>Standard</h3>
                        <p>Pour les entreprises en croissance</p>
                    </div>
                    <div class="pricing-price">
                        <span class="price">€499</span>
                        <span class="period">/mois</span>
                    </div>
                    <ul class="pricing-features">
                        <li><i data-lucide="check" class="check"></i> 26-100 employés</li>
                        <li><i data-lucide="check" class="check"></i> Tout du plan Starter +</li>
                        <li><i data-lucide="check" class="check"></i> Gestion sous-traitants</li>
                        <li><i data-lucide="check" class="check"></i> DPIA automatisées</li>
                        <li><i data-lucide="check" class="check"></i> Intégrations (Google, Microsoft)</li>
                        <li><i data-lucide="check" class="check"></i> Revue DPO trimestrielle</li>
                        <li><i data-lucide="check" class="check"></i> Support prioritaire</li>
                    </ul>
                    <a href="#contact" class="btn-card btn-card-primary">Commencer</a>
                </div>

                <div class="pricing-card">
                    <div class="pricing-header">
                        <h3>Avancé</h3>
                        <p>Pour les grandes organisations</p>
                    </div>
                    <div class="pricing-price">
                        <span class="price">€999</span>
                        <span class="period">/mois</span>
                    </div>
                    <ul class="pricing-features">
                        <li><i data-lucide="check" class="check"></i> 100+ employés</li>
                        <li><i data-lucide="check" class="check"></i> Tout du plan Professional +</li>
                        <li><i data-lucide="check" class="check"></i> DPO dédié</li>
                        <li><i data-lucide="check" class="check"></i> API & webhooks</li>
                        <li><i data-lucide="check" class="check"></i> SSO (SAML/OAuth2)</li>
                        <li><i data-lucide="check" class="check"></i> Portail public de confiance</li>
                        <li><i data-lucide="check" class="check"></i> Support 24/7</li>
                        <li><i data-lucide="check" class="check"></i> SLA garanti</li>
                    </ul>
                    <a href="#contact" class="btn-card">Nous Contacter</a>
                </div>
            </div>
            <div class="pricing-footer">
                <p><strong>Évaluation complète unique :</strong> €2500 (micro-entreprise) | €7500 (moyenne entreprise) | €15 000 (grande entreprise)</p>
            </div>
        </div>
    </section>

    <!-- Monaco Made Section -->
    <section class="monaco-made">
        <div class="container">
            <div class="monaco-made-content">
                <div class="monaco-made-text">
                    <span class="section-tag">100% monégasque</span>
                    <h2>Développé et Hébergé à Monaco</h2>
                    <p>MonacoRGPD est une solution entièrement conçue, développée et hébergée dans la Principauté de Monaco. Vos données restent sur le territoire monégasque, garantissant une souveraineté totale et une conformité parfaite avec la législation locale.</p>
                    <ul class="monaco-features">
                        <li><i data-lucide="map-pin" class="check"></i> Équipe basée à Monaco</li>
                        <li><i data-lucide="server" class="check"></i> Hébergement exclusif Monaco/EU</li>
                        <li><i data-lucide="shield" class="check"></i> Souveraineté des données garantie</li>
                        <li><i data-lucide="scale" class="check"></i> Conformité loi n° 1.565</li>
                    </ul>
                </div>
                <div class="monaco-made-logo">
                    <p class="monaco-badge">en partenariat avec</p>
                    <img src="images/monacocloud.png" alt="Monaco Cloud - Hébergé à Monaco" class="monaco-logo">
                </div>
            </div>
        </div>
    </section>

    <!-- Trust Section -->
    <section class="trust">
        <div class="container">
            <div class="section-header">
                <h2>Pourquoi nous faire confiance ?</h2>
            </div>
            <div class="trust-grid">
                <div class="trust-card">
                    <i data-lucide="graduation-cap" class="trust-icon-large"></i>
                    <h3>DPO Expert Monaco</h3>
                    <p>Notre équipe comprend des DPO qualifiés avec une expertise spécifique de la législation monégasque</p>
                </div>
                <div class="trust-card">
                    <i data-lucide="building-2" class="trust-icon-large"></i>
                    <h3>Aligné avec l'APDP</h3>
                    <p>Workflows de notification directe et intégration des templates officiels de l'autorité de protection</p>
                </div>
                <div class="trust-card">
                    <i data-lucide="lock" class="trust-icon-large"></i>
                    <h3>Sécurité Maximale</h3>
                    <p>Hébergement EU/Monaco, chiffrement AES-256, authentification multi-facteurs, audits annuels</p>
                </div>
                <div class="trust-card">
                    <i data-lucide="globe" class="trust-icon-large"></i>
                    <h3>Convention 108+</h3>
                    <p>Conformité avec les engagements internationaux de Monaco en matière de protection des données</p>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section id="contact" class="cta">
        <div class="container">
            <div class="cta-content">
                <h2>Prêt à simplifier votre conformité RGPD ?</h2>
                <p>Rejoignez les entreprises monégasques qui ont choisi MonacoRGPD</p>
                <div class="cta-buttons">
                    <a href="mailto:contact@monacogdpr.mc" class="btn-primary btn-large">Demander une démo gratuite</a>
                    <a href="tel:+37797702244" class="btn-outline btn-large"><i data-lucide="phone" style="width: 20px; height: 20px; display: inline-block; vertical-align: middle; margin-right: 8px;"></i>Appelez-nous</a>
                </div>
                <p class="cta-note">Évaluation initiale gratuite • Sans engagement • Mise en place en 48h</p>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-col">
                    <a href="/" class="footer-logo">
                        <i data-lucide="shield-check" class="logo-icon" style="color: white;"></i>
                        <span class="logo-text"><span style="color: red;">Monaco</span>RGPD</span>
                    </a>
                    <p>La plateforme de conformité RGPD conçue pour les entreprises monégasques.</p>
                </div>
                <div class="footer-col">
                    <h4>Produit</h4>
                    <ul>
                        <li><a href="#fonctionnalites">Fonctionnalités</a></li>
                        <li><a href="#tarifs">Tarifs</a></li>
                        <li><a href="/documentation">Documentation</a></li>
                    </ul>
                </div>
                <div class="footer-col">
                    <h4>Ressources</h4>
                    <ul>
                        <li><a href="https://legimonaco.mc/tnc/loi/2024/12-03-1.565" target="_blank">Loi n° 1.565</a></li>
                        <li><a href="https://apdp.mc" target="_blank">APDP Monaco</a></li>
                        <li><a href="/guides-pratiques">Guides Pratiques</a></li>
                    </ul>
                </div>
                <div class="footer-col">
                    <h4>Contact</h4>
                    <ul>
                        <li><a href="mailto:contact@monacogdpr.mc">contact@monacogdpr.mc</a></li>
                        <li><a href="tel:+37797702244">+377 97 70 22 44</a></li>
                        <li>Monaco, Principauté de Monaco</li>
                    </ul>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2025 MonacoGDPR. Tous droits réservés.</p>
                <div class="footer-links">
                    <a href="/mentions-legales">Mentions Légales</a>
                    <a href="/confidentialite">Politique de Confidentialité</a>
                    <a href="/conditions-utilisation">CGU</a>
                </div>
            </div>
        </div>
    </footer>