//
//  InfoWindowController.swift
//  usd-menu-bar
//
//  Created by Paulo Paiva on 22/12/25.
//

import Cocoa

/// Protocol for info window controller delegate
protocol InfoWindowControllerDelegate: AnyObject {
    func infoWindowControllerDidRequestRefetch(_ controller: InfoWindowController)
    func infoWindowControllerDidRequestQuit(_ controller: InfoWindowController)
}

/// Controller responsible for managing the info window
final class InfoWindowController {
    
    // MARK: - Properties
    
    weak var delegate: InfoWindowControllerDelegate?
    
    private var window: NSWindow?
    private var statusLabel: NSTextField?
    private var refetchButton: NSButton?
    
    // MARK: - Public Methods
    
    /// Shows the info window, creating it if necessary
    func show(with status: DollarStatus) {
        if window == nil {
            createWindow()
        }
        
        updateContent(for: status)
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Updates the window content based on the current dollar status
    func updateContent(for status: DollarStatus) {
        guard let statusLabel = statusLabel else { return }
        
        switch status {
        case .idle:
            statusLabel.stringValue = "Initializing..."
            statusLabel.textColor = .labelColor
        case .loading:
            statusLabel.stringValue = "⏳ Updating rate..."
            statusLabel.textColor = .secondaryLabelColor
        case .success(let value):
            statusLabel.stringValue = "1 USD = R$ \(value)"
            statusLabel.textColor = .systemGreen
        case .error:
            statusLabel.stringValue = "⚠️ Error fetching data"
            statusLabel.textColor = .systemRed
        }
        
        // Update refetch button
        refetchButton?.isEnabled = !status.isLoading
        refetchButton?.title = status.isLoading ? "Refetching..." : "Refetch"
    }
    
    // MARK: - Private Methods
    
    private func createWindow() {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 240),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        newWindow.title = "USD Menu Bar"
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        
        let contentView = NSView(frame: newWindow.contentView!.bounds)
        contentView.wantsLayer = true
        
        // Title label
        let titleLabel = NSTextField(labelWithString: "💵 USD/BRL Exchange Rate")
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 20, y: 180, width: 280, height: 30)
        contentView.addSubview(titleLabel)
        
        // Status label
        let statusLabelView = NSTextField(labelWithString: "Initializing...")
        statusLabelView.font = NSFont.monospacedDigitSystemFont(ofSize: 24, weight: .medium)
        statusLabelView.textColor = .labelColor
        statusLabelView.alignment = .center
        statusLabelView.frame = NSRect(x: 20, y: 130, width: 280, height: 30)
        contentView.addSubview(statusLabelView)
        statusLabel = statusLabelView
        
        // Info label
        let infoLabel = NSTextField(labelWithString: "Updates every 60 seconds")
        infoLabel.font = NSFont.systemFont(ofSize: 12)
        infoLabel.textColor = .secondaryLabelColor
        infoLabel.alignment = .center
        infoLabel.frame = NSRect(x: 20, y: 95, width: 280, height: 20)
        contentView.addSubview(infoLabel)
        
        // Buttons layout
        let buttonWidth: CGFloat = 110
        let buttonSpacing: CGFloat = 20
        let totalButtonWidth = buttonWidth * 2 + buttonSpacing
        let buttonStartX = (320 - totalButtonWidth) / 2
        
        // Refetch button
        let refetchBtn = NSButton(title: "Refetch", target: self, action: #selector(handleRefetch))
        refetchBtn.bezelStyle = .rounded
        refetchBtn.frame = NSRect(x: buttonStartX, y: 45, width: buttonWidth, height: 32)
        contentView.addSubview(refetchBtn)
        refetchButton = refetchBtn
        
        // Quit button
        let quitButton = NSButton(title: "Quit", target: self, action: #selector(handleQuit))
        quitButton.bezelStyle = .rounded
        quitButton.frame = NSRect(x: buttonStartX + buttonWidth + buttonSpacing, y: 45, width: buttonWidth, height: 32)
        contentView.addSubview(quitButton)
        
        // API info label
        let apiLabel = NSTextField(labelWithString: "Data from open.er-api.com")
        apiLabel.font = NSFont.systemFont(ofSize: 10)
        apiLabel.textColor = .tertiaryLabelColor
        apiLabel.alignment = .center
        apiLabel.frame = NSRect(x: 20, y: 15, width: 280, height: 16)
        contentView.addSubview(apiLabel)
        
        newWindow.contentView = contentView
        window = newWindow
    }
    
    // MARK: - Actions
    
    @objc private func handleRefetch() {
        delegate?.infoWindowControllerDidRequestRefetch(self)
    }
    
    @objc private func handleQuit() {
        delegate?.infoWindowControllerDidRequestQuit(self)
    }
}

