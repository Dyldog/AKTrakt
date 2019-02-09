//
//  ViewController.swift
//  AKTrakt_TvOS_Example
//
//  Created by Florian Morello on 25/11/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import AKTrakt
import AlamofireImage

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var movies: [TraktMovie] = []
    var shows: [TraktShow] = []

    lazy var trakt: Trakt = {
        return Trakt.autoload()
    } ()

    var loadedOnce: Bool = false

	override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !loadedOnce {
            load()
        }

        if trakt.hasValidToken() {
            loadUser()
        }
    }

    @IBAction func displayAuth() {
		if let vc = TraktAuthenticationViewController.credientialViewController(trakt: trakt, delegate: self) {
			present(vc, animated: true, completion: nil)
        }
    }

    func load() {
        loadedOnce = true
		TraktRequestTrending(type: TraktMovie.self, extended: .Images, pagination: TraktPagination(page: 1, limit: 10)).request(trakt: trakt) { [weak self] objects, error in
			if let movies = objects?.compactMap({ $0.media }) {
                self?.movies = movies
				self?.collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
            } else {
                print(error)
            }
        }
		TraktRequestTrending(type: TraktShow.self, extended: .Images, pagination: TraktPagination(page: 1, limit: 20)).request(trakt: trakt) { [weak self] objects, error in
			if let shows = objects?.compactMap({ $0.media }) {
                self?.shows = shows
				self?.collectionView.reloadSections(NSIndexSet(index: 1) as IndexSet)
            } else {
                print(error)
            }
        }
    }

    func loadUser() {
		TraktRequestProfile().request(trakt: trakt) { user, error in
            self.title = user?["username"] as? String
        }
    }

    @IBAction func clearToken(sender: AnyObject) {
        trakt.clearToken()
        title = "Trakt"
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? MovieViewController, let movie = sender as? TraktMovie {
            vc.movie = movie
		} else if let vc = segue.destination as? ShowViewController, let show = sender as? TraktShow {
            vc.show = show
        }
    }
}

extension ViewController: TraktAuthViewControllerDelegate {
    func TraktAuthViewControllerDidAuthenticate(controller: UIViewController) {
        loadUser()
		dismiss(animated: true, completion: nil)
    }

    func TraktAuthViewControllerDidCancel(controller: UIViewController) {
		dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {

	func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? movies.count : shows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return collectionView.dequeueReusableCell(withReuseIdentifier: "movie", for: indexPath as IndexPath)
    }

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
			if let image = (cell.viewWithTag(1) as? UIImageView), let url = movies[indexPath.row].imageURL(type: .Poster, thatFits: image) {
				image.af_setImage(withURL: url as URL, placeholderImage: nil)
            }
		} else if indexPath.section == 1, let image = (cell.viewWithTag(1) as? UIImageView), let url = shows[indexPath.row].imageURL(type: .Poster, thatFits: image) {
			image.af_setImage(withURL: url as URL, placeholderImage: nil)
        }
    }

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
			performSegue(withIdentifier: "movie", sender: movies[indexPath.row])
        } else {
			performSegue(withIdentifier: "show", sender: shows[indexPath.row])
        }
    }
}
