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
    private let imageSubject: PublishSubject<Data> = PublishSubject<Data>()
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
        viewModel = ViewModel(id3TagEditor: ID3TagEditor(),
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
    let version: Variable<Int?>
    let trackPosition: Variable<String?>
    let totalTracks: Variable<String?>
    let genreIdentifier: Variable<Int?>
    let genreDescription: Variable<String?>

    init(id3TagEditor: ID3TagEditor,
         path: Observable<String>,
         image: PublishSubject<Data>,
         updateAction: Observable<Void>) {
        title = Variable<String?>(nil)
        artist = Variable<String?>(nil)
        album = Variable<String?>(nil)
        year = Variable<String?>(nil)
        version = Variable<Int?>(3)
        trackPosition = Variable<String?>(nil)
        totalTracks = Variable<String?>(nil)
        genreIdentifier = Variable<Int?>(nil)
        genreDescription = Variable<String?>(nil)
        path.subscribe(onNext: { (path) in
            let id3Tag = try! id3TagEditor.read(from: path)
            self.version.value = Int(id3Tag!.properties.version.rawValue)
            self.title.value = id3Tag?.title
            self.artist.value = id3Tag?.artist
            self.album.value = id3Tag?.album
            self.year.value = id3Tag?.year
            if let trackPosition = id3Tag?.trackPosition {
                self.trackPosition.value = String(trackPosition.position)
                if let totalTracks = trackPosition.totalTracks {
                    self.totalTracks.value = String(totalTracks)
                }
            }
            if let genre = id3Tag?.genre {
                self.genreIdentifier.value = genre.identifier?.rawValue
                self.genreDescription.value = genre.description
            }
            if let validAttachedPictures = id3Tag?.attachedPictures {
                image.onNext(validAttachedPictures[0].art)
            }
        }).disposed(by: disposeBag)
        
        let validVersion = version.asObservable().map { (versionSelected) -> ID3Version in
            return ID3Version(rawValue: UInt8(versionSelected ?? 0)) ?? .version3
        }
        
        let trackPositionInSet = Observable.combineLatest(
            trackPosition.asObservable(),
            totalTracks.asObservable()
        ) { (trackPosition, totalTracks) -> TrackPositionInSet? in
            if let validTrackPositionAsString = trackPosition,
                let validTrackPosition = Int(validTrackPositionAsString) {
                return TrackPositionInSet(position: validTrackPosition, totalTracks: Int(totalTracks ?? ""))
            }
            return nil
        }
        
        let genre = Observable.combineLatest(
            genreIdentifier.asObservable(),
            genreDescription.asObservable()
        ) { (genreIdentifier, genreDescription) -> Genre? in
            if let validGenre = genreIdentifier,
                let validId3Genre = ID3Genre(rawValue: validGenre) {
                return Genre(genre: validId3Genre, description: genreDescription)
            }
            return nil
        }
        
        let image = image.map({ (imageData) -> AttachedPicture in
            return AttachedPicture(art: imageData, type: .FrontCover, format: .Png)
        })
        
        let input = Observable.combineLatest(
            title.asObservable(),
            artist.asObservable(),
            album.asObservable(),
            year.asObservable(),
            validVersion,
            trackPositionInSet,
            genre,
            image
        ) { (title, artist, album, year, version, trackPositionInSet, genre, image) -> ID3Tag in
            return ID3Tag(
                version: version,
                artist: artist,
                album: album,
                title: title,
                year: year,
                genre: genre,
                attachedPictures: [image],
                trackPosition: trackPositionInSet
            )
        }
        
        Observable
            .combineLatest(updateAction, input, path)
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

extension Reactive where Base: NSPopUpButton {
    public var selectedItemTag: ControlProperty<Int?> {
        return base.rx.controlProperty(
            getter: { control in
                return control.selectedItem?.tag
            },
            setter: { control, tag in
                if let validTag = tag {
                    control.tag = validTag
                    control.selectItem(withTag: validTag)
                }
            }
        )
    }
}


