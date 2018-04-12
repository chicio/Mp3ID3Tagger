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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }
    
    func bindViewModel() {
        viewModel = ViewModel(id3TagEditor: ID3TagEditor(),
                              path: pathSubject.asObservable(),
                              updateDriver: updateButton.rx.tap.asDriver())
        (titleTextField.rx.text <-> viewModel.title).disposed(by: disposeBag)
        (artistTextField.rx.text <-> viewModel.artist).disposed(by: disposeBag)
        (albumTextField.rx.text <-> viewModel.album).disposed(by: disposeBag)
        (yearTextField.rx.text <-> viewModel.year).disposed(by: disposeBag)
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

class ViewModel {
    let disposeBag = DisposeBag()
    let title: Variable<String?>
    let artist: Variable<String?>
    let album: Variable<String?>
    let year: Variable<String?>
    let version: Variable<ID3Version?>
    
    init(id3TagEditor: ID3TagEditor,
         path: Observable<String>,
         updateDriver: Driver<Void>) {
        title = Variable<String?>("")
        artist = Variable<String?>("")
        album = Variable<String?>("")
        year = Variable<String?>("")
        version = Variable<ID3Version?>(.version2)
        path.subscribe(onNext: { (path) in
            let id3Tag = try! id3TagEditor.read(from: path)
            self.title.value = id3Tag?.title
            self.artist.value = id3Tag?.artist
            self.album.value = id3Tag?.album
            self.year.value = id3Tag?.year
        }).disposed(by: disposeBag)
        
        let input = Observable.combineLatest(
            title.asObservable(),
            artist.asObservable(),
            album.asObservable(),
            year.asObservable()
        ) { (title, artist, album, year) -> ID3Tag in
            return ID3Tag(
                version: .version3,
                artist: artist,
                album: album,
                title: title,
                year: year,
                genre: nil,
                attachedPictures: nil,
                trackPosition: nil
            )
        }
        
        Observable
            .combineLatest(updateDriver.asObservable(), input, path)
            .subscribe { event -> Void in
                try! id3TagEditor.write(tag: event.element!.1, to: event.element!.2)
            }
            .disposed(by: disposeBag)
    }
}

infix operator <-> : DefaultPrecedence

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return CompositeDisposable(bindToUIDisposable, bindToVariable)
}
