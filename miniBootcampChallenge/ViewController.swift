//
//  ViewController.swift
//  miniBootcampChallenge
//

import UIKit

class ViewController: UICollectionViewController {
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
    private lazy var urls: [URL] = URLProvider.urls
    
    private var isLoading = true
    private var loadedImages = [UIImage]() {
        didSet {
            // Once the downloaded images match the total of the ones being fetched we know we're done
            if loadedImages.count == urls.count {
                self.isLoading = false
                loaderView.stopAnimating()
                // reload the collectionView
                self.collectionView.reloadData()
                
            }
        }
    }
    private var loaderView = LoaderViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        setupLoaderView()
        fetchImages()
    }
}


extension ViewController {
    
    // Fetches all images and adds them to our 'loadedImages' array
    func fetchImages() {
        for (index, _) in urls.enumerated() {
            loadListOfImagesFrom(url: urls[index])
        }
    }
    
    // A cute animated loader
    func setupLoaderView() {
        loaderView = LoaderViewController(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        loaderView.center = view.center
        view.addSubview(loaderView)
        loaderView.startAnimating()
    }
    
    // TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way
    func loadListOfImagesFrom(url: URL) {
        if let url = URL(string: url.absoluteString) {
            // This should be async to keep the UI from freezing 🥶
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    // Use the data to create a UIImage view
                    let image = UIImage(data: data!)
                    self.loadedImages.append(image!)
                }
            }.resume()
        }
    }
    // TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.
    func populateCollectionView(with image: UIImage, for cell: ImageCell) {
        // Populates the cell with the UIImage view
        cell.display(image)
    }
}


// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If we're still loading there's no need to create cells yet
        if !isLoading {
            return loadedImages.count
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        // Once we finish loading we populate the collectionView
        if !isLoading {
            populateCollectionView(with: loadedImages[indexPath.row], for: cell)
        }
        return cell
    }
}


// MARK: - UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.cellSize == nil {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (Constants.columns * Constants.cellSpacing - 1)
            Constants.cellSize = (view.frame.size.width - emptySpace) / Constants.columns
        }
        return CGSize(width: Constants.cellSize!, height: Constants.cellSize!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
}
