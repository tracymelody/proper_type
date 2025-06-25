import Cocoa
import Foundation
import Carbon

// Real AI Service that calls OpenAI API
class AIService {
    static let shared = AIService()
    private init() {}
    
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    private let defaultModel = "gpt-4o-mini"
    
    func improveText(_ text: String, systemPrompt: String, completion: @escaping (String?) -> Void) {
        // Check if API key is configured
        guard let apiKey = getAPIKey(), !apiKey.isEmpty else {
            print("❌ OpenAI API key not configured")
            DispatchQueue.main.async {
                completion("❌ Error: OpenAI API key not set. Please configure your API key first.")
            }
            return
        }
        
        print("🚀 Using OpenAI API with model: \(defaultModel)")
        print("🔑 API key configured: \(String(apiKey.prefix(10)))...")
        print("📝 Processing text: \(text)")
        
        // Prepare the request
        let messages = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": "Please improve this text while maintaining its original meaning: \(text)"]
        ]
        
        let requestBody: [String: Any] = [
            "model": defaultModel,
            "messages": messages,
            "max_tokens": 500,
            "temperature": 0.3
        ]
        
        guard let url = URL(string: apiURL),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            DispatchQueue.main.async {
                completion("❌ Error: Failed to create API request")
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("📡 Sending request to OpenAI...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ API request error: \(error)")
                    completion("❌ Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    completion("❌ No data received from OpenAI")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        
                        // Check for API errors
                        if let error = json["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            print("❌ OpenAI API error: \(message)")
                            completion("❌ OpenAI error: \(message)")
                            return
                        }
                        
                        // Extract improved text
                        if let choices = json["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let message = firstChoice["message"] as? [String: Any],
                           let content = message["content"] as? String {
                            
                            let improvedText = content.trimmingCharacters(in: .whitespacesAndNewlines)
                            print("✅ Received improved text from OpenAI")
                            completion(improvedText)
                        } else {
                            print("❌ Unexpected API response format")
                            completion("❌ Unexpected response format")
                        }
                    } else {
                        print("❌ Invalid JSON response")
                        completion("❌ Invalid response format")
                    }
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    completion("❌ Failed to parse response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func getAPIKey() -> String? {
        return UserDefaults.standard.string(forKey: "ProperType_OpenAI_API_Key")
    }
    
    func setAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "ProperType_OpenAI_API_Key")
    }
}

// Settings Manager with enhanced configuration
class SettingsManager {
    static let shared = SettingsManager()
    private init() {}
    
    private let systemPromptKey = "ProperType_SystemPrompt"
    
    func getCurrentSystemPrompt() -> String {
        let defaultPrompt = """
        You are a professional text editor and writing assistant. Your task is to improve the given text by:
        
        1. Fixing grammar, spelling, and punctuation errors
        2. Improving clarity and readability
        3. Making the language more professional and polished
        4. Maintaining the original meaning and intent
        5. Keeping the same tone unless it's clearly inappropriate
        
        Please return only the improved text without explanations, quotes, or additional commentary.
        If the text is already well-written, you may make minor improvements or return it as-is.
        """
        
        return UserDefaults.standard.string(forKey: systemPromptKey) ?? defaultPrompt
    }
    
    func setCustomSystemPrompt(_ prompt: String) {
        UserDefaults.standard.set(prompt, forKey: systemPromptKey)
        print("💾 Custom system prompt saved")
    }
    
    func resetSystemPromptToDefault() {
        UserDefaults.standard.removeObject(forKey: systemPromptKey)
        print("🔄 System prompt reset to default")
    }
    
    func getHotkeyDescription() -> String {
        return "⌘⌥I"
    }
}

// Enhanced Permission Manager
class PermissionManager {
    static let shared = PermissionManager()
    private init() {}
    
    func checkAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
    
    func requestAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
    
    func openAccessibilityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}

// Global Hotkey Manager using NSEvent (more reliable than Carbon)
class HotkeyManager {
    static let shared = HotkeyManager()
    private init() {}
    
    private var monitor: Any?
    private var callback: (() -> Void)?
    
    func registerHotkey(callback: @escaping () -> Void) {
        unregisterHotkey()
        
        self.callback = callback
        
        // Check if we have accessibility permissions first
        let trusted = PermissionManager.shared.checkAccessibilityPermissions()
        if !trusted {
            print("❌ Cannot register hotkey - accessibility permissions not granted")
            return
        }
        
        print("🎯 Registering hotkey ⌘⌥I with NSEvent monitor...")
        
        // Monitor key down events globally for Cmd+Option+I
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Check if this matches our hotkey (Command+Option+I)
            let modifierFlags = event.modifierFlags.intersection([.command, .option, .control, .shift])
            if event.keyCode == 34 && modifierFlags == [.command, .option] { // 34 is 'I' key
                print("🔥 Hotkey detected! Cmd+Option+I pressed")
                DispatchQueue.main.async {
                    self?.callback?()
                }
            }
        }
        
        if monitor != nil {
            print("✅ Hotkey monitor registered successfully")
        } else {
            print("❌ Failed to register hotkey monitor")
        }
    }
    
    func unregisterHotkey() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
            print("🗑️ Hotkey monitor removed")
        }
        callback = nil
    }
}

// Main Menu Bar App with Enhanced Permission Handling
class ProperTypeMenuApp: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let aiService = AIService.shared
    private let settingsManager = SettingsManager.shared
    private let hotkeyManager = HotkeyManager.shared
    private let permissionManager = PermissionManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 ProperType Enhanced Menu Bar App starting...")
        
        setupStatusBarItem()
        checkAndSetupPermissions()
        
        print("✅ ProperType Enhanced Menu Bar App launched successfully")
    }
    
    private func checkAndSetupPermissions() {
        let hasPermissions = permissionManager.checkAccessibilityPermissions()
        
        if hasPermissions {
            print("✅ Accessibility permissions granted")
            setupHotkey()
        } else {
            print("⚠️ Accessibility permissions not granted")
            
            // Show the permission request dialog after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.promptForPermissions()
            }
        }
    }
    
    private func promptForPermissions() {
        let alert = NSAlert()
        alert.messageText = "Enable Hotkey Support?"
        alert.informativeText = """
        ProperType can work with or without global hotkeys:
        
        WITH HOTKEYS (⌘⌥I):
        • Press ⌘⌥I anywhere to improve selected text
        • Requires accessibility permission
        
        WITHOUT HOTKEYS:
        • Use menu actions only
        • Select text, copy it, then use "Improve Clipboard Text"
        
        Would you like to enable hotkey support?
        """
        
        alert.addButton(withTitle: "Enable Hotkeys")
        alert.addButton(withTitle: "Use Menu Only")
        alert.addButton(withTitle: "Open System Preferences")
        
        let response = alert.runModal()
        
        switch response {
        case .alertFirstButtonReturn: // Enable Hotkeys
            let granted = permissionManager.requestAccessibilityPermissions()
            if granted {
                setupHotkey()
                showNotification(message: "✅ Hotkey ⌘⌥I enabled!")
            } else {
                showNotification(message: "⚠️ Permission required. Check System Preferences → Privacy & Security → Accessibility")
            }
            
        case .alertSecondButtonReturn: // Use Menu Only
            showNotification(message: "📱 ProperType ready! Use menu actions to improve text.")
            
        case .alertThirdButtonReturn: // Open System Preferences
            permissionManager.openAccessibilityPreferences()
            showNotification(message: "🔧 Please add ProperType to Accessibility and restart the app")
            
        default:
            break
        }
        
        // Update menu to reflect current state
        updateMenu()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.unregisterHotkey()
    }
    
    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.title = "PT"
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
        
        updateMenu()
    }
    
    private func setupHotkey() {
        hotkeyManager.registerHotkey { [weak self] in
            self?.processSelectedText()
        }
        
        print("🔥 Hotkey setup complete: ⌘⌥I")
    }
    
    private func updateMenu() {
        let menu = NSMenu()
        
        // Main actions
        let improveClipboardItem = NSMenuItem(title: "Improve Clipboard Text", action: #selector(improveClipboardText), keyEquivalent: "")
        improveClipboardItem.target = self
        menu.addItem(improveClipboardItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Hotkey action
        let hasPermissions = permissionManager.checkAccessibilityPermissions()
        let hotkeyTitle = hasPermissions ? "Process Selected Text (⌘⌥I)" : "Process Selected Text (Needs Permission)"
        let processSelectedItem = NSMenuItem(title: hotkeyTitle, action: #selector(processSelectedText), keyEquivalent: "")
        processSelectedItem.target = self
        if !hasPermissions {
            processSelectedItem.isEnabled = false
        }
        menu.addItem(processSelectedItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Permission management
        if !hasPermissions {
            let enableHotkeyItem = NSMenuItem(title: "Enable Hotkey Support", action: #selector(enableHotkeys), keyEquivalent: "")
            enableHotkeyItem.target = self
            menu.addItem(enableHotkeyItem)
            menu.addItem(NSMenuItem.separator())
        }
        
        // Debugging
        let showClipboardItem = NSMenuItem(title: "Show Clipboard Content", action: #selector(showClipboardContent), keyEquivalent: "")
        showClipboardItem.target = self
        menu.addItem(showClipboardItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Configuration
        let configAPIItem = NSMenuItem(title: "Configure OpenAI API Key", action: #selector(configureAPIKey), keyEquivalent: "")
        configAPIItem.target = self
        menu.addItem(configAPIItem)
        
        let configPromptItem = NSMenuItem(title: "Configure AI Instructions", action: #selector(configureSystemPrompt), keyEquivalent: "")
        configPromptItem.target = self
        menu.addItem(configPromptItem)
        
        // Status
        let hasAPIKey = aiService.getAPIKey() != nil && !aiService.getAPIKey()!.isEmpty
        let apiKeyStatusText = hasAPIKey ? "✅ API Key Configured" : "❌ API Key Not Set"
        let statusMenuItem = NSMenuItem(title: apiKeyStatusText, action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        let hotkeyStatusText = hasPermissions ? "✅ Hotkeys Enabled" : "⚠️ Hotkeys Disabled"
        let hotkeyStatusItem = NSMenuItem(title: hotkeyStatusText, action: nil, keyEquivalent: "")
        hotkeyStatusItem.isEnabled = false
        menu.addItem(hotkeyStatusItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit ProperType", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func statusBarButtonClicked() {
        // Menu will show automatically
    }
    
    @objc private func enableHotkeys() {
        let granted = permissionManager.requestAccessibilityPermissions()
        if granted {
            setupHotkey()
            updateMenu()
            showNotification(message: "✅ Hotkey ⌘⌥I enabled!")
        } else {
            let alert = NSAlert()
            alert.messageText = "Permission Required"
            alert.informativeText = "To enable hotkeys, please:\n\n1. Go to System Preferences\n2. Privacy & Security → Accessibility\n3. Add ProperType and enable it\n4. Restart ProperType"
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "OK")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                permissionManager.openAccessibilityPreferences()
            }
        }
    }
    
    @objc private func processSelectedText() {
        print("🎯 Processing selected text...")
        
        // Check if API key is configured
        guard let apiKey = aiService.getAPIKey(), !apiKey.isEmpty else {
            print("❌ API key not configured")
            showNotification(message: "❌ API key not configured")
            return
        }
        
        // Check permissions again
        guard permissionManager.checkAccessibilityPermissions() else {
            showNotification(message: "❌ Accessibility permission required for hotkeys")
            return
        }
        
        // Store current clipboard content
        let pasteboard = NSPasteboard.general
        let originalClipboard = pasteboard.string(forType: .string)
        
        // Show processing notification
        showNotification(message: "🤖 Processing selected text...")
        
        // Clear clipboard
        pasteboard.clearContents()
        
        // Copy selected text (Cmd+C)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sendKeyboardShortcut(keyCode: 8, modifiers: .command) // Cmd+C
            
            // Wait for clipboard to update
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                
                let newClipboard = pasteboard.string(forType: .string)
                guard let selectedText = newClipboard, 
                      !selectedText.isEmpty,
                      selectedText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
                    self.showNotification(message: "❌ No text selected")
                    // Restore clipboard
                    if let original = originalClipboard {
                        pasteboard.clearContents()
                        pasteboard.setString(original, forType: .string)
                    }
                    return
                }
                
                // Process with AI
                let systemPrompt = self.settingsManager.getCurrentSystemPrompt()
                self.aiService.improveText(selectedText, systemPrompt: systemPrompt) { [weak self] improvedText in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        if let improved = improvedText, !improved.hasPrefix("❌") {
                            // Put improved text in clipboard
                            pasteboard.clearContents()
                            pasteboard.setString(improved, forType: .string)
                            
                            // Paste the improved text (Cmd+V)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.sendKeyboardShortcut(keyCode: 9, modifiers: .command) // Cmd+V
                                self.showNotification(message: "✅ Text improved!")
                            }
                        } else {
                            self.showNotification(message: improvedText ?? "❌ Failed to improve text")
                            // Restore clipboard
                            if let original = originalClipboard {
                                pasteboard.clearContents()
                                pasteboard.setString(original, forType: .string)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func improveClipboardText() {
        print("📋 Improving clipboard text...")
        
        // Check if API key is configured
        guard let apiKey = aiService.getAPIKey(), !apiKey.isEmpty else {
            showAlert(title: "API Key Required", message: "Please configure your OpenAI API key first.")
            return
        }
        
        // Get current clipboard content
        let pasteboard = NSPasteboard.general
        guard let originalText = pasteboard.string(forType: .string), 
              !originalText.isEmpty else {
            showAlert(title: "No Text Found", message: "Please copy some text to the clipboard first.")
            return
        }
        
        showNotification(message: "🤖 Improving clipboard text...")
        
        // Process with AI
        let systemPrompt = settingsManager.getCurrentSystemPrompt()
        aiService.improveText(originalText, systemPrompt: systemPrompt) { [weak self] improvedText in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let improved = improvedText, !improved.hasPrefix("❌") {
                    // Replace clipboard content with improved text
                    pasteboard.clearContents()
                    pasteboard.setString(improved, forType: .string)
                    
                    self.showNotification(message: "✅ Clipboard text improved!")
                    print("✅ Clipboard updated with improved text")
                } else {
                    self.showAlert(title: "Improvement Failed", 
                                 message: improvedText ?? "Failed to improve text")
                }
            }
        }
    }
    
    private func sendKeyboardShortcut(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: false)
        
        keyDown?.flags = CGEventFlags(rawValue: UInt64(modifiers.rawValue))
        keyUp?.flags = CGEventFlags(rawValue: UInt64(modifiers.rawValue))
        
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
    
    @objc private func showClipboardContent() {
        let pasteboard = NSPasteboard.general
        let content = pasteboard.string(forType: .string) ?? "Empty"
        let truncated = content.count > 200 ? String(content.prefix(200)) + "..." : content
        
        showAlert(title: "Clipboard Content", message: "Current clipboard:\n\n\(truncated)")
    }
    
    @objc private func configureAPIKey() {
        let alert = NSAlert()
        alert.messageText = "Configure OpenAI API Key"
        alert.informativeText = "Enter your OpenAI API key:"
        
        let textField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.stringValue = aiService.getAPIKey() ?? ""
        alert.accessoryView = textField
        
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        
        alert.window.initialFirstResponder = textField
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let apiKey = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            aiService.setAPIKey(apiKey)
            updateMenu()
            showNotification(message: apiKey.isEmpty ? "❌ API key cleared" : "✅ API key saved")
        }
    }
    
    @objc private func configureSystemPrompt() {
        let alert = NSAlert()
        alert.messageText = "Configure AI Instructions"
        alert.informativeText = "Customize how the AI processes your text:"
        
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
        let textView = NSTextView(frame: scrollView.bounds)
        textView.string = settingsManager.getCurrentSystemPrompt()
        textView.isRichText = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        alert.accessoryView = scrollView
        
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Reset to Default")
        alert.addButton(withTitle: "Cancel")
        
        alert.window.initialFirstResponder = textView
        
        let response = alert.runModal()
        
        switch response {
        case .alertFirstButtonReturn: // Save
            let prompt = textView.string.trimmingCharacters(in: .whitespacesAndNewlines)
            settingsManager.setCustomSystemPrompt(prompt)
            showNotification(message: "✅ AI instructions saved")
            
        case .alertSecondButtonReturn: // Reset
            settingsManager.resetSystemPromptToDefault()
            showNotification(message: "🔄 AI instructions reset to default")
            
        default: // Cancel
            break
        }
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showNotification(message: String) {
        print("🔔 \(message)")
        
        // Simple notification - we'll just print for now since NSUserNotification is deprecated
        // In a real app, you'd use UserNotifications framework
    }
}

// Application Setup
let app = NSApplication.shared
let delegate = ProperTypeMenuApp()
app.delegate = delegate

// Hide dock icon since this is a menu bar app
app.setActivationPolicy(.accessory)

print("🚀 Starting ProperType Enhanced...")
app.run()
