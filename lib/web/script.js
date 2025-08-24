// DOM Elements
const loginToggle = document.getElementById('loginToggle');
const registerToggle = document.getElementById('registerToggle');
const loginForm = document.getElementById('loginForm');
const registerForm = document.getElementById('registerForm');
const toggleSlider = document.querySelector('.toggle-slider');
const loadingOverlay = document.getElementById('loadingOverlay');
const successModal = document.getElementById('successModal');

// State Management
let currentView = 'login';
let formData = {};
let validationErrors = {};

// Initialize App
document.addEventListener('DOMContentLoaded', function() {
    initializeEventListeners();
    initializeFormValidation();
    showWelcomeAnimation();
    setupPasswordStrengthIndicator();
});

// Event Listeners
function initializeEventListeners() {
    // Toggle between login and register
    loginToggle.addEventListener('click', () => switchToLogin());
    registerToggle.addEventListener('click', () => switchToRegister());
    
    // Form submissions
    loginForm.addEventListener('submit', handleLogin);
    registerForm.addEventListener('submit', handleRegister);
    
    // Social login buttons
    document.querySelectorAll('.social-btn').forEach(btn => {
        btn.addEventListener('click', handleSocialLogin);
    });
    
    // Forgot password link
    document.querySelector('.forgot-password').addEventListener('click', handleForgotPassword);
    
    // Input focus animations
    document.querySelectorAll('input, select').forEach(input => {
        input.addEventListener('focus', handleInputFocus);
        input.addEventListener('blur', handleInputBlur);
        input.addEventListener('input', handleInputChange);
    });
    
    // Keyboard navigation
    document.addEventListener('keydown', handleKeyboardNavigation);
    
    // Password confirmation validation for register form
    const confirmPasswordInput = registerForm.querySelector('input[placeholder="Confirm Password"]');
    if (confirmPasswordInput) {
        confirmPasswordInput.addEventListener('input', validatePasswordMatch);
    }
}

// Form Switching Functions
function switchToLogin() {
    if (currentView === 'login') return;
    
    currentView = 'login';
    
    // Update toggle buttons
    loginToggle.classList.add('active');
    registerToggle.classList.remove('active');
    
    // Move slider
    toggleSlider.classList.remove('register');
    
    // Switch forms with animation
    registerForm.classList.add('hidden');
    setTimeout(() => {
        loginForm.classList.remove('hidden');
        loginForm.classList.add('show-login');
        
        // Reset register form
        registerForm.reset();
        clearValidationErrors(registerForm);
    }, 200);
    
    // Update page title
    updatePageTitle('Login - AgriDirect');
}

function switchToRegister() {
    if (currentView === 'register') return;
    
    currentView = 'register';
    
    // Update toggle buttons
    registerToggle.classList.add('active');
    loginToggle.classList.remove('active');
    
    // Move slider
    toggleSlider.classList.add('register');
    
    // Switch forms with animation
    loginForm.classList.add('hidden');
    setTimeout(() => {
        registerForm.classList.remove('hidden');
        registerForm.classList.add('show-register');
        
        // Reset login form
        loginForm.reset();
        clearValidationErrors(loginForm);
    }, 200);
    
    // Update page title
    updatePageTitle('Register - AgriDirect');
}

// Form Submission Handlers
async function handleLogin(e) {
    e.preventDefault();
    
    const formData = new FormData(loginForm);
    const email = loginForm.querySelector('input[type="email"]').value;
    const password = loginForm.querySelector('input[type="password"]').value;
    const rememberMe = loginForm.querySelector('input[type="checkbox"]').checked;
    
    // Validate form
    if (!validateLoginForm(email, password)) {
        return;
    }
    
    // Show loading
    showLoading('Signing you in...');
    
    try {
        // Simulate API call
        const result = await simulateLogin(email, password, rememberMe);
        
        if (result.success) {
            // Store user data
            storeUserData(result.user);
            
            // Show success and redirect
            hideLoading();
            showSuccessModal('Welcome back!', 'Redirecting to your dashboard...');
            
            setTimeout(() => {
                redirectToDashboard();
            }, 2000);
        } else {
            hideLoading();
            showError(result.message || 'Login failed. Please try again.');
        }
    } catch (error) {
        hideLoading();
        showError('Network error. Please check your connection and try again.');
        console.error('Login error:', error);
    }
}

async function handleRegister(e) {
    e.preventDefault();
    
    const inputs = registerForm.querySelectorAll('input, select');
    const userData = {};
    
    inputs.forEach(input => {
        if (input.type === 'checkbox') {
            userData[input.name || getInputName(input)] = input.checked;
        } else {
            userData[input.name || getInputName(input)] = input.value;
        }
    });
    
    // Validate form
    if (!validateRegistrationForm(userData)) {
        return;
    }
    
    // Show loading
    showLoading('Creating your account...');
    
    try {
        // Simulate API call
        const result = await simulateRegistration(userData);
        
        if (result.success) {
            // Store user data
            storeUserData(result.user);
            
            // Show success modal
            hideLoading();
            showSuccessModal('Account Created!', 'Welcome to AgriDirect! Setting up your profile...');
            
            setTimeout(() => {
                redirectToDashboard();
            }, 3000);
        } else {
            hideLoading();
            showError(result.message || 'Registration failed. Please try again.');
        }
    } catch (error) {
        hideLoading();
        showError('Network error. Please check your connection and try again.');
        console.error('Registration error:', error);
    }
}

// Social Login Handler
function handleSocialLogin(e) {
    const provider = e.currentTarget.classList.contains('google') ? 'google' :
                    e.currentTarget.classList.contains('facebook') ? 'facebook' : 'apple';
    
    showLoading(`Connecting with ${provider.charAt(0).toUpperCase() + provider.slice(1)}...`);
    
    // Simulate social login
    setTimeout(() => {
        hideLoading();
        showSuccessModal('Connected!', `Successfully connected with ${provider}. Redirecting...`);
        
        setTimeout(() => {
            redirectToDashboard();
        }, 2000);
    }, 2000);
}

// Forgot Password Handler
function handleForgotPassword(e) {
    e.preventDefault();
    
    const email = prompt('Enter your email address to reset password:');
    if (email && validateEmail(email)) {
        showLoading('Sending reset link...');
        
        // Simulate sending reset email
        setTimeout(() => {
            hideLoading();
            alert('Password reset link sent to your email!');
        }, 2000);
    } else if (email) {
        showError('Please enter a valid email address.');
    }
}

// Input Handlers
function handleInputFocus(e) {
    const inputGroup = e.target.closest('.input-group');
    if (inputGroup) {
        inputGroup.classList.add('focused');
    }
}

function handleInputBlur(e) {
    const inputGroup = e.target.closest('.input-group');
    if (inputGroup) {
        inputGroup.classList.remove('focused');
    }
    
    // Validate on blur
    validateField(e.target);
}

function handleInputChange(e) {
    // Clear previous validation errors
    clearFieldError(e.target);
    
    // Real-time validation for certain fields
    if (e.target.type === 'email') {
        debounce(() => validateField(e.target), 500)();
    } else if (e.target.type === 'password') {
        if (currentView === 'register') {
            updatePasswordStrength(e.target.value);
        }
    }
}

// Keyboard Navigation
function handleKeyboardNavigation(e) {
    if (e.key === 'Tab') {
        // Handle tab navigation
        return;
    } else if (e.key === 'Enter') {
        // Submit form on Enter
        const activeElement = document.activeElement;
        if (activeElement && activeElement.tagName !== 'BUTTON') {
            const form = activeElement.closest('form');
            if (form && !form.classList.contains('hidden')) {
                form.querySelector('button[type="submit"]').click();
            }
        }
    } else if (e.key === 'Escape') {
        // Close modals
        if (!successModal.classList.contains('hidden')) {
            hideSuccessModal();
        }
    }
}

// Password Toggle Function
function togglePassword(icon) {
    const input = icon.parentElement.querySelector('input');
    const isPassword = input.type === 'password';
    
    input.type = isPassword ? 'text' : 'password';
    icon.classList.toggle('fa-eye');
    icon.classList.toggle('fa-eye-slash');
    
    // Add animation
    icon.style.transform = 'scale(0.8)';
    setTimeout(() => {
        icon.style.transform = 'scale(1)';
    }, 150);
}

// Validation Functions
function validateLoginForm(email, password) {
    let isValid = true;
    
    if (!email || !validateEmail(email)) {
        showFieldError(loginForm.querySelector('input[type="email"]'), 'Please enter a valid email address');
        isValid = false;
    }
    
    if (!password || password.length < 6) {
        showFieldError(loginForm.querySelector('input[type="password"]'), 'Password must be at least 6 characters');
        isValid = false;
    }
    
    return isValid;
}

function validateRegistrationForm(userData) {
    let isValid = true;
    const inputs = registerForm.querySelectorAll('input, select');
    
    inputs.forEach(input => {
        if (!validateField(input)) {
            isValid = false;
        }
    });
    
    // Additional validation for password match
    const passwords = registerForm.querySelectorAll('input[type="password"]');
    if (passwords.length >= 2 && passwords[0].value !== passwords[1].value) {
        showFieldError(passwords[1], 'Passwords do not match');
        isValid = false;
    }
    
    return isValid;
}

function validateField(field) {
    const value = field.value.trim();
    const placeholder = field.placeholder.toLowerCase();
    let isValid = true;
    let errorMessage = '';
    
    // Required field validation
    if (field.hasAttribute('required') && !value) {
        errorMessage = `${placeholder.charAt(0).toUpperCase() + placeholder.slice(1)} is required`;
        isValid = false;
    } else if (value) {
        // Specific field validation
        if (field.type === 'email' && !validateEmail(value)) {
            errorMessage = 'Please enter a valid email address';
            isValid = false;
        } else if (field.type === 'tel' && !validatePhone(value)) {
            errorMessage = 'Please enter a valid phone number';
            isValid = false;
        } else if (field.type === 'password' && value.length < 6) {
            errorMessage = 'Password must be at least 6 characters';
            isValid = false;
        } else if (placeholder.includes('name') && value.length < 2) {
            errorMessage = 'Name must be at least 2 characters';
            isValid = false;
        }
    }
    
    if (!isValid) {
        showFieldError(field, errorMessage);
    } else {
        clearFieldError(field);
    }
    
    return isValid;
}

function validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

function validatePhone(phone) {
    const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/;
    return phoneRegex.test(phone.replace(/[\s\-\(\)]/g, ''));
}

function validatePasswordMatch() {
    const passwords = registerForm.querySelectorAll('input[type="password"]');
    if (passwords.length >= 2) {
        const password = passwords[0].value;
        const confirmPassword = passwords[1].value;
        
        if (confirmPassword && password !== confirmPassword) {
            showFieldError(passwords[1], 'Passwords do not match');
        } else {
            clearFieldError(passwords[1]);
        }
    }
}

// Error Display Functions
function showFieldError(field, message) {
    clearFieldError(field);
    
    const inputGroup = field.closest('.input-group');
    const errorElement = document.createElement('div');
    errorElement.className = 'field-error';
    errorElement.textContent = message;
    errorElement.style.cssText = `
        color: #e74c3c;
        font-size: 12px;
        margin-top: 5px;
        animation: slideDown 0.3s ease;
    `;
    
    inputGroup.appendChild(errorElement);
    field.style.borderColor = '#e74c3c';
}

function clearFieldError(field) {
    const inputGroup = field.closest('.input-group');
    const errorElement = inputGroup.querySelector('.field-error');
    if (errorElement) {
        errorElement.remove();
    }
    field.style.borderColor = '#e9ecef';
}

function clearValidationErrors(form) {
    const errors = form.querySelectorAll('.field-error');
    errors.forEach(error => error.remove());
    
    const inputs = form.querySelectorAll('input, select');
    inputs.forEach(input => {
        input.style.borderColor = '#e9ecef';
    });
}

// UI Helper Functions
function showLoading(message = 'Loading...') {
    const spinner = loadingOverlay.querySelector('.loading-spinner p');
    spinner.textContent = message;
    loadingOverlay.classList.remove('hidden');
}

function hideLoading() {
    loadingOverlay.classList.add('hidden');
}

function showSuccessModal(title, message) {
    const modal = successModal.querySelector('.modal');
    modal.querySelector('h3').textContent = title;
    modal.querySelector('p').textContent = message;
    successModal.classList.remove('hidden');
}

function hideSuccessModal() {
    successModal.classList.add('hidden');
}

function showError(message) {
    // Create a temporary error toast
    const toast = document.createElement('div');
    toast.className = 'error-toast';
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: #e74c3c;
        color: white;
        padding: 15px 20px;
        border-radius: 10px;
        box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
        z-index: 3000;
        animation: slideInRight 0.3s ease;
        max-width: 300px;
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

// Password Strength Indicator
function setupPasswordStrengthIndicator() {
    const passwordInput = registerForm.querySelector('input[type="password"]');
    if (!passwordInput) return;
    
    const strengthIndicator = document.createElement('div');
    strengthIndicator.className = 'password-strength';
    strengthIndicator.innerHTML = `
        <div class="strength-bar">
            <div class="strength-fill"></div>
        </div>
        <div class="strength-text">Password strength</div>
    `;
    
    strengthIndicator.style.cssText = `
        margin-top: 8px;
        font-size: 12px;
    `;
    
    passwordInput.closest('.input-group').appendChild(strengthIndicator);
}

function updatePasswordStrength(password) {
    const strengthIndicator = registerForm.querySelector('.password-strength');
    if (!strengthIndicator) return;
    
    const strengthFill = strengthIndicator.querySelector('.strength-fill');
    const strengthText = strengthIndicator.querySelector('.strength-text');
    
    let strength = 0;
    let strengthLabel = 'Very Weak';
    let color = '#e74c3c';
    
    if (password.length >= 6) strength += 1;
    if (password.match(/[a-z]/)) strength += 1;
    if (password.match(/[A-Z]/)) strength += 1;
    if (password.match(/[0-9]/)) strength += 1;
    if (password.match(/[^a-zA-Z0-9]/)) strength += 1;
    
    switch (strength) {
        case 0:
        case 1:
            strengthLabel = 'Very Weak';
            color = '#e74c3c';
            break;
        case 2:
            strengthLabel = 'Weak';
            color = '#f39c12';
            break;
        case 3:
            strengthLabel = 'Fair';
            color = '#f1c40f';
            break;
        case 4:
            strengthLabel = 'Good';
            color = '#27ae60';
            break;
        case 5:
            strengthLabel = 'Strong';
            color = '#2ecc71';
            break;
    }
    
    const width = (strength / 5) * 100;
    strengthFill.style.cssText = `
        width: ${width}%;
        height: 4px;
        background: ${color};
        border-radius: 2px;
        transition: all 0.3s ease;
    `;
    
    strengthText.textContent = `Password strength: ${strengthLabel}`;
    strengthText.style.color = color;
}

// API Simulation Functions
async function simulateLogin(email, password, rememberMe) {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    // Mock validation
    if (email === 'demo@agridirect.com' && password === 'demo123') {
        return {
            success: true,
            user: {
                id: 1,
                name: 'Demo User',
                email: email,
                farmType: 'Crop Farming',
                location: 'Gujarat'
            },
            token: 'mock-jwt-token'
        };
    } else {
        return {
            success: false,
            message: 'Invalid email or password'
        };
    }
}

async function simulateRegistration(userData) {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 2500));
    
    // Mock successful registration
    return {
        success: true,
        user: {
            id: Date.now(),
            name: userData.name || userData['Full Name'],
            email: userData.email || userData['Email Address'],
            phone: userData.phone || userData['Phone Number'],
            state: userData.state,
            farmType: userData.farmType,
        },
        token: 'mock-jwt-token-new'
    };
}

// Data Management
function storeUserData(user) {
    // Store in memory (since localStorage is not available)
    window.currentUser = user;
}

function getUserData() {
    return window.currentUser || null;
}

// Navigation
function redirectToDashboard() {
    // In a real app, this would navigate to the dashboard
    // For now, we'll show an alert
    alert('Welcome to AgriDirect! Dashboard loading...\n\nDemo Login:\nEmail: demo@agridirect.com\nPassword: demo123');
    
    // Reset the form for demo purposes
    hideSuccessModal();
    if (currentView === 'register') {
        switchToLogin();
    }
}

// Utility Functions
function updatePageTitle(title) {
    document.title = title;
}

function getInputName(input) {
    return input.placeholder.toLowerCase().replace(/\s+/g, '');
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

function showWelcomeAnimation() {
    // Add a subtle animation to the header
    const header = document.querySelector('.header');
    header.style.transform = 'translateY(-20px)';
    header.style.opacity = '0';
    
    setTimeout(() => {
        header.style.transition = 'all 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
        header.style.transform = 'translateY(0)';
        header.style.opacity = '1';
    }, 100);
}

// Initialize Form Validation
function initializeFormValidation() {
    // Add CSS for animations
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(100%); }
            to { opacity: 1; transform: translateX(0); }
        }
        
        @keyframes slideOutRight {
            from { opacity: 1; transform: translateX(0); }
            to { opacity: 0; transform: translateX(100%); }
        }
        
        .input-group.focused {
            transform: translateY(-2px);
        }
        
        .password-strength .strength-bar {
            width: 100%;
            height: 4px;
            background: #e9ecef;
            border-radius: 2px;
            margin-bottom: 5px;
            overflow: hidden;
        }
    `;
    document.head.appendChild(style);
}

// Export functions for potential external use
window.AgriDirectAuth = {
    switchToLogin,
    switchToRegister,
    togglePassword,
    validateEmail,
    validatePhone
};