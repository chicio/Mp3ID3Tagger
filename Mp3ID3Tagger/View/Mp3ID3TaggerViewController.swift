//
//  ViewController.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 30.03.18.
//

import Cocoa
import RxSwift
import RxCocoa
import ID3TagEditor

class Mp3ID3TaggerViewController: NSViewController, BindableView {
    private let disposeBag: DisposeBag = DisposeBag()
    private let pathSubject: PublishSubject<String> = PublishSubject<String>()
    private let imageSubject: PublishSubject<Data> = PublishSubject<Data>()
    var viewModel: Mp3ID3TaggerViewModel!
    @IBOutlet weak var versionPopUpbutton: NSPopUpButton!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var artistTextField: NSTextField!
    @IBOutlet weak var albumTextField: NSTextField!
    @IBOutlet weak var yearTextField: NSTextField!
    @IBOutlet weak var trackPositionTextField: NSTextField!
    @IBOutlet weak var totalTracksTextField: NSTextField!
    @IBOutlet weak var genrePopUpMenu: NSPopUpButton!
    @IBOutlet weak var genreDescriptionTextField: NSTextField!
    @IBOutlet weak var imageSelectionButton: NSButton!
    @IBOutlet weak var updateButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        imageSelectionButton.rx.tap.subscribe(onNext: { tap in
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = true
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseDirectories = false
            openPanel.canCreateDirectories = false
            openPanel.title = "Select an Image file"
            openPanel.beginSheetModal(for: self.view.window!) { (response) in
                if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                    if let selectedUrl = openPanel.url {
                        let image = try! Data(contentsOf: selectedUrl)
                        self.imageSubject.onNext(image)
                        self.imageSelectionButton.image = NSImage(data: image)
                    }
                }
                openPanel.close()
            }
        }).disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        viewModel = Mp3ID3TaggerViewModel(id3TagEditor: ID3TagEditor(),
                                          path: pathSubject.asObservable(),
                                          image: imageSubject,
                                          updateAction: updateButton.rx.tap.asObservable())
        (titleTextField.rx.text <-> viewModel.title).disposed(by: disposeBag)
        (artistTextField.rx.text <-> viewModel.artist).disposed(by: disposeBag)
        (albumTextField.rx.text <-> viewModel.album).disposed(by: disposeBag)
        (yearTextField.rx.text <-> viewModel.year).disposed(by: disposeBag)
        (versionPopUpbutton.rx.selectedItemTag <-> viewModel.version).disposed(by: disposeBag)
        (trackPositionTextField.rx.text <-> viewModel.trackPosition).disposed(by: disposeBag)
        (totalTracksTextField.rx.text <-> viewModel.totalTracks).disposed(by: disposeBag)
        (genrePopUpMenu.rx.selectedItemTag <-> viewModel.genreIdentifier).disposed(by: disposeBag)
        (genreDescriptionTextField.rx.text <-> viewModel.genreDescription).disposed(by: disposeBag)
        imageSubject.subscribe(onNext: { (data) in
            self.imageSelectionButton.image = NSImage(data: data)
        }).disposed(by: disposeBag)
        viewModel
            .save
            .asObservable()
            .subscribe(onNext: { (result) in
                let alert = NSAlert()
                alert.addButton(withTitle: "Ok")
                if result == true {
                    alert.messageText = "Mp3 saved correctly!"
                } else {
                    alert.messageText = "Error during save!"
                }
                alert.runModal()
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.title = "Select an MP3 file"
        openPanel.beginSheetModal(for: self.view.window!) { (response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let selectedPath = openPanel.url?.path {
                    self.pathSubject.onNext(selectedPath)
                }
            }
            openPanel.close()
        }
    }
}

