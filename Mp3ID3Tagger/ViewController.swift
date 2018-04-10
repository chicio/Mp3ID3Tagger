//
//  ViewController.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 30.03.18.
//  Copyright © 2018 Fabrizio Duroni. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa
import ID3TagEditor

class ViewController: NSViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private let pathSubject: PublishSubject<String> = PublishSubject<String>()
    private var viewModel: ViewModel!
    @IBOutlet weak var versionPopUpbutton: NSPopUpButton!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var artistTextField: NSTextField!
    @IBOutlet weak var albumTextField: NSTextField!
    @IBOutlet weak var yearTextField: NSTextField!
    @IBOutlet weak var trackPositionTextField: NSTextField!
    @IBOutlet weak var totalTracksTextField: NSTextField!
    @IBOutlet weak var genrePopUpMenu: NSPopUpButton!
    @IBOutlet weak var genreDescriptionTextField: NSTextField!
    @IBOutlet weak var updateButton: NSButton!
    
    func bindViewModel() {
//        let id3TagStartingInput = Observable.combineLatest(
//            titleTextField.rx.observe(String.self, "stringValue"),
//            artistTextField.rx.observe(String.self, "stringValue"),
//            albumTextField.rx.observe(String.self, "stringValue"),
//            yearTextField.rx.observe(String.self, "stringValue"),
//            resultSelector: { (title, artist, album, year) -> ID3Tag in
//                return ID3Tag(version: .version3,
//                              artist: artist,
//                              album: album,
//                              title: title,
//                              year: year,
//                              genre: nil,
//                              attachedPictures: nil,
//                              trackPosition: nil)
//        })
        let id3TagInputWhenChange = Observable.combineLatest(
            titleTextField.rx.text,
            artistTextField.rx.text,
            albumTextField.rx.text,
            yearTextField.rx.text,
            resultSelector: { (title, artist, album, year) -> ID3Tag in
                return ID3Tag(version: .version3,
                              artist: artist,
                              album: album,
                              title: title,
                              year: year,
                              genre: nil,
                              attachedPictures: nil,
                              trackPosition: nil)
        })
//        let id3TagInput = Observable.merge(id3TagStartingInput, id3TagInputWhenChange) //test zip
        viewModel = ViewModel(id3TagEditor: ID3TagEditor(),
                              pathDriver: pathSubject.asDriver(onErrorJustReturn: ""),
                              updateDriver: updateButton.rx.tap.asDriver(),
                              inputDriver: id3TagInputWhenChange)
        
        viewModel.title.drive(titleTextField.rx.text).disposed(by: disposeBag)
        viewModel.artist.drive(artistTextField.rx.text).disposed(by: disposeBag)
        viewModel.album.drive(albumTextField.rx.text).disposed(by: disposeBag)
        viewModel.year.drive(yearTextField.rx.text).disposed(by: disposeBag)
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
                    self.bindViewModel()
                    self.pathSubject.onNext(selectedPath)
                }
            }
            openPanel.close()
        }
    }
}

class ViewModel {
    let disposeBag = DisposeBag()
    var title: Driver<String?>
    var artist: Driver<String?>
    var album: Driver<String?>
    let year: Driver<String?>
    let id3TagDriver: Driver<ID3Tag?>
    
    init(id3TagEditor: ID3TagEditor,
         pathDriver: Driver<String>,
         updateDriver: Driver<Void>,
         inputDriver: Observable<ID3Tag>) {
        id3TagDriver = pathDriver.map { (path) -> ID3Tag? in
            return try! id3TagEditor.read(from: path)
        }
        title = id3TagDriver.map({ $0?.title }).asDriver()
        artist = id3TagDriver.map({ $0?.artist }).asDriver()
        album = id3TagDriver.map({ $0?.album }).asDriver()
        year = id3TagDriver.map({ $0?.year }).asDriver()
       
        Observable
            .combineLatest(updateDriver.asObservable(), inputDriver, pathDriver.asObservable())
            .subscribe { event -> Void in
                try! id3TagEditor.write(tag: event.element!.1, to: event.element!.2)
            }
            .disposed(by: disposeBag)
    }
}

