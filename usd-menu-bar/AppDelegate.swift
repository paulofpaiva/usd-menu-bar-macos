//
//  AppDelegate.swift
//  usd-menu-bar
//
//  Created by Paulo Paiva on 22/12/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    private var statusBarController: StatusBarController!
    private var infoWindowController: InfoWindowController!
    private var exchangeRateService: ExchangeRateService!
    private var refreshTimer: Timer?
    
    private var status: DollarStatus = .idle {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.statusBarController.updateDisplay(for: self.status)
                self.infoWindowController.updateContent(for: self.status)
            }
        }
    }
    
    // MARK: - Constants
    
    private let refreshInterval: TimeInterval = 60.0
    
    // MARK: - App Lifecycle
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Close any windows opened automatically by the storyboard
        for window in NSApp.windows {
            window.close()
        }
        
        setupControllers()
        startRefreshTimer()
        fetchExchangeRate()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        refreshTimer?.invalidate()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setupControllers() {
        // Initialize service
        exchangeRateService = ExchangeRateService()
        
        // Initialize status bar controller
        statusBarController = StatusBarController()
        statusBarController.delegate = self
        
        // Initialize info window controller
        infoWindowController = InfoWindowController()
        infoWindowController.delegate = self
    }
    
    // MARK: - Timer
    
    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.fetchExchangeRate()
        }
    }
    
    // MARK: - Data Fetching
    
    private func fetchExchangeRate() {
        status = .loading
        
        exchangeRateService.fetchRate { [weak self] result in
            switch result {
            case .success(let rate):
                self?.status = .success(rate)
            case .failure:
                self?.status = .error
            }
        }
    }
}

// MARK: - StatusBarControllerDelegate

extension AppDelegate: StatusBarControllerDelegate {
    
    func statusBarControllerDidRequestRefetch(_ controller: StatusBarController) {
        fetchExchangeRate()
    }
    
    func statusBarControllerDidRequestOpen(_ controller: StatusBarController) {
        infoWindowController.show(with: status)
    }
    
    func statusBarControllerDidRequestQuit(_ controller: StatusBarController) {
        NSApp.terminate(nil)
    }
}

// MARK: - InfoWindowControllerDelegate

extension AppDelegate: InfoWindowControllerDelegate {
    
    func infoWindowControllerDidRequestRefetch(_ controller: InfoWindowController) {
        fetchExchangeRate()
    }
    
    func infoWindowControllerDidRequestQuit(_ controller: InfoWindowController) {
        NSApp.terminate(nil)
    }
}
