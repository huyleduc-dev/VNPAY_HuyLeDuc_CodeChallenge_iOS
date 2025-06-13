//
//  PhotoListViewController.swift
//  VNPAY_HuyLeDuc_CodeChallenge_iOS
//
//  Created by Đức Huy Lê on 12/6/25.
//

import UIKit

class PhotoListViewController: UIViewController {
    //MARK: - UI Properties
    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    // Array of photos to be displayed (can be filtered).
    private var photos: [Photo] = []
    // Master array for all loaded photos.
    private var allPhotos: [Photo] = []

    private var currentPage = 1
    private var isLoading = false

    // Repository instance for fetching photos and images.
    private let repository: PhotoRepository = PhotoRepositoryImpl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSearchBar()
        loadPhotos(page: currentPage)
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        searchBar.placeholder = "Search for ID or Author name"
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Enabling image prefetching.
        tableView.prefetchDataSource = self
        
        tableView.register(PhotoCell.self, forCellReuseIdentifier: "PhotoCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        // Add pull-to-refresh.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    @objc private func refreshData() {
        currentPage = 1
        photos.removeAll()
        isLoading = true
        loadPhotos(page: currentPage)
    }

    // Loads photos from the repository.
    private func loadPhotos(page: Int) {
        repository.fetchPhotos(page: page, limit: 100) { [weak self] photos in
            guard let self = self else { return }
            if let photos = photos {
                DispatchQueue.main.async {
                    if page == 1 {
                        // For the first page, set both master and display arrays.
                        self.allPhotos = photos
                        self.photos = photos
                    } else {
                        // Append new results for subsequent pages.
                        self.allPhotos.append(contentsOf: photos)
                        self.photos.append(contentsOf: photos)
                    }
                    self.tableView.reloadData()
                    self.isLoading = false
                    self.tableView.refreshControl?.endRefreshing()
                    
                    // Update table view footer
                    let footer = UILabel()
                    footer.text = self.isLoading ? "loading..." : nil
                    footer.textAlignment = .center
                    self.tableView.tableFooterView = footer
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension PhotoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        // Ensure the index is within bounds.
        if indexPath.row < photos.count {
            let photo = photos[indexPath.row]
            let repository = PhotoRepositoryImpl()
            cell.configure(with: photo, repository: repository)
        }
        return cell
    }
    
    // Deselects the cell and dismisses the keyboard when a cell is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
    }
    
    // Implements infinite scrolling by checking if the user has scrolled near the bottom.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height && !isLoading {
            isLoading = true
            currentPage += 1
            loadPhotos(page: currentPage)
        }
    }
    
}

//MARK: - UISearchBarDelegate
extension PhotoListViewController: UISearchBarDelegate {
    
    // Filters photos in real time as the text changes.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let validatedText = validateSearchText(searchText)
        searchBar.text = validatedText
        
        // When search text is empty, show all loaded photos.
        if validatedText.isEmpty {
            photos = allPhotos
            tableView.reloadData()
        } else {
            // Filter photos by author name or exact ID match.
            let filteredPhotos = allPhotos.filter {
                $0.author.lowercased().contains(validatedText.lowercased()) || $0.id == validatedText
            }
            photos = filteredPhotos
            tableView.reloadData()
        }
    }
    
    // Validates and limits the search text input.
    private func validateSearchText(_ text: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*():.,<>/\\[]?")
        let filtered = text.unicodeScalars.filter { allowedCharacters.contains($0) }
        return String(filtered.prefix(15))
    }
    
    // Dismisses the keyboard and filters photos when the search button is clicked.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar.text ?? ""
        let filteredPhotos = allPhotos.filter {
            $0.author.lowercased().contains(searchText.lowercased()) || $0.id == searchText
        }
        if filteredPhotos.isEmpty {
            print("No photos found matching \(searchText)")
        }
        photos = filteredPhotos
        tableView.reloadData()
    }
}

//MARK: - UIScrollViewDelegate
extension PhotoListViewController: UIScrollViewDelegate {
    // Hides the keyboard when the user starts scrolling the table view.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

//MARK: - UITableViewDataSourcePrefetching
extension PhotoListViewController: UITableViewDataSourcePrefetching {
    // Prefetches images for upcoming cells to improve scrolling performance.
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row < photos.count {
                let photo = photos[indexPath.row]
                // Initiate image prefetch. The completion can be ignored.
                repository.loadImage(from: photo.downloadUrl) { _ in }
            }
        }
    }
}


