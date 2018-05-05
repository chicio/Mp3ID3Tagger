//
//  Mp3ID3TaggerViewController.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 30/03/18.
//

import Cocoa
import RxSwift
import RxCocoa
import ID3TagEditor

class Mp3ID3TaggerViewController: NSViewController, BindableView {
    private let disposeBag: DisposeBag = DisposeBag()
    private let openAction: PublishSubject<String> = PublishSubject<String>()
    private let saveAction: PublishSubject<Void> = PublishSubject<Void>()
    private let stringToID3ImageExtensionAdapter = StringToID3ImageExtensionAdapter()
    var viewModel: Mp3ID3TaggerViewModel!
    @IBOutlet weak var versionPopUpbutton: NSPopUpButton!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var artistTextField: NSTextField!
    @IBOutlet weak var albumTextField: NSTextField!
    @IBOutlet weak var albumArtistField: NSTextField!
    @IBOutlet weak var yearTextField: NSTextField!
    @IBOutlet weak var trackPositionTextField: NSTextField!
    @IBOutlet weak var totalTracksTextField: NSTextField!
    @IBOutlet weak var genrePopUpMenu: NSPopUpButton!
    @IBOutlet weak var genreDescriptionTextField: NSTextField!
    @IBOutlet weak var imageSelectionButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }
    
    func bindViewModel() {
        viewModel = Mp3ID3TaggerViewModel(openAction: openAction.asObservable(), saveAction: saveAction.asObservable())
        (titleTextField.rx.text <-> viewModel.form.basicSongFields.title).disposed(by: disposeBag)
        (artistTextField.rx.text <-> viewModel.form.basicSongFields.artist).disposed(by: disposeBag)
        (albumTextField.rx.text <-> viewModel.form.basicSongFields.album).disposed(by: disposeBag)
        (albumArtistField.rx.text <-> viewModel.form.basicSongFields.albumArtist).disposed(by: disposeBag)
        (yearTextField.rx.text <-> viewModel.form.basicSongFields.year).disposed(by: disposeBag)
        (versionPopUpbutton.rx.selectedItemTag <-> viewModel.form.versionField.version).disposed(by: disposeBag)
        (trackPositionTextField.rx.text <-> viewModel.form.trackPositionInSetFields.trackPosition).disposed(by: disposeBag)
        (totalTracksTextField.rx.text <-> viewModel.form.trackPositionInSetFields.totalTracks).disposed(by: disposeBag)
        (genrePopUpMenu.rx.selectedItemTag <-> viewModel.form.genreFields.genreIdentifier).disposed(by: disposeBag)
        (genreDescriptionTextField.rx.text <-> viewModel.form.genreFields.genreDescription).disposed(by: disposeBag)
        self.bindAttachedPictureField()
        self.bindSaveAction()
    }
    
    private func bindAttachedPictureField() {
        viewModel
            .form
            .attachedPictureField
            .attachedPicture
            .asObservable()
            .filter({ $0 != nil })
            .subscribe(onNext: { self.imageSelectionButton.image = NSImage(data: $0!.data) })
            .disposed(by: disposeBag)
        imageSelectionButton.rx.tap.subscribe(onNext: { tap in
            NSOpenPanel.display(in: self.view.window!,
                                fileTypes: ["png", "jpg", "jpeg"],
                                title: "Select an Image file",
                                onOkResponse: self.openImage)
        }).disposed(by: disposeBag)
    }
    
    private func bindSaveAction() {
        viewModel.saveResult
            .asObservable()
            .subscribe(onNext: { (result) in
                let alert = NSAlert()
                alert.addButton(withTitle: "Ok")
                alert.messageText = result ? "Mp3 saved correctly!" : "Error during save!"
                alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func openImage(imageUrl: URL) {
        if let image = try? Data(contentsOf: imageUrl) {
            let type = self.stringToID3ImageExtensionAdapter.adapt(format: imageUrl.pathExtension)
            self.viewModel.form.attachedPictureField.attachedPicture.value = ImageWithType(data: image, format: type)
            self.imageSelectionButton.image = NSImage(data: image)
        }
    }

    @IBAction func open(_ sender: Any?) {
        NSOpenPanel.display(in: self.view.window!,
                            fileTypes: ["mp3"],
                            title: "Select an MP3 file",
                            onOkResponse: {
                                self.openAction.onNext($0.path)
                                self.fileNameLabel.stringValue = $0.lastPathComponent
        })
    }
    
    @IBAction func save(_ sender: Any?) {
        saveAction.onNext(())
    }
}
