//
//  StatusBarController.swift
//  usd-menu-bar
//
//  Created by Paulo Paiva on 22/12/25.
//

import Cocoa

/// Protocol for status bar controller delegate
protocol StatusBarControllerDelegate: AnyObject {
    func statusBarControllerDidRequestRefetch(_ controller: StatusBarController)
    func statusBarControllerDidRequestOpen(_ controller: StatusBarController)
    func statusBarControllerDidRequestQuit(_ controller: StatusBarController)
}

/// Controller responsible for managing the menu bar status item and menu
final class StatusBarController {
    
    // MARK: - Properties
    
    weak var delegate: StatusBarControllerDelegate?
    
    private var statusItem: NSStatusItem!
    private var statusMenu: NSMenu!
    private var refetchMenuItem: NSMenuItem?
    
    // MARK: - Initialization
    
    init() {
        setupStatusBar()
        setupMenu()
    }
    
    // MARK: - Setup
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "USD ..."
    }
    
    private func setupMenu() {
        statusMenu = NSMenu()
        
        // Open item
        let openItem = NSMenuItem(title: "Open", action: #selector(handleOpen), keyEquivalent: "o")
        openItem.target = self
        statusMenu.addItem(openItem)
        
        // Refetch item
        let refetchItem = NSMenuItem(title: "Refetch", action: #selector(handleRefetch), keyEquivalent: "r")
        refetchItem.target = self
        statusMenu.addItem(refetchItem)
        refetchMenuItem = refetchItem
        
        // Separator
        statusMenu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit", action: #selector(handleQuit), keyEquivalent: "q")
        quitItem.target = self
        statusMenu.addItem(quitItem)
        
        statusItem.menu = statusMenu
    }
    
    // MARK: - Public Methods
    
    /// Updates the status bar display based on the current dollar status
    func updateDisplay(for status: DollarStatus) {
        guard let button = statusItem.button else { return }
        
        switch status {
        case .idle:
            button.attributedTitle = NSAttributedString(string: "USD ...")
            
        case .loading:
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.systemGreen,
                .font: NSFont.systemFont(ofSize: 14, weight: .medium)
            ]
            button.attributedTitle = NSAttributedString(string: "⏳ Updating rate...", attributes: attributes)
            
        case .success(let value):
            let formattedValue = String(format: "USD $ %.2f", value)
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.systemGreen,
                .font: NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
            ]
            button.attributedTitle = NSAttributedString(string: formattedValue, attributes: attributes)
            
        case .error:
            button.attributedTitle = NSAttributedString(string: "USD ⚠️")
        }
        
        // Update refetch menu item
        refetchMenuItem?.isEnabled = !status.isLoading
        refetchMenuItem?.title = status.isLoading ? "Refetching..." : "Refetch"
    }
    
    // MARK: - Actions
    
    @objc private func handleOpen() {
        delegate?.statusBarControllerDidRequestOpen(self)
    }
    
    @objc private func handleRefetch() {
        delegate?.statusBarControllerDidRequestRefetch(self)
    }
    
    @objc private func handleQuit() {
        delegate?.statusBarControllerDidRequestQuit(self)
    }
}

