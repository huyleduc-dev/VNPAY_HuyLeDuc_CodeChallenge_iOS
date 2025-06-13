//
//  PhotoCell.swift
//  VNPAY_HuyLeDuc_CodeChallenge_iOS
//
//  Created by Đức Huy Lê on 12/6/25.
//

import UIKit

class PhotoCell: UITableViewCell {
    
    //MARK: - UI Components
    private let photoImageView = UIImageView()
    private let idLabel = UILabel()
    private let authorLabel = UILabel()
    private let sizeLabel = UILabel()
    private var aspectRatioConstraint: NSLayoutConstraint?
    
    // The current image download task; used to cancel any ongoing image loading when reusing the cell.
    private var imageTask: URLSessionDataTask?

    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Cell Reuse
    // Prepares the cell for reuse by canceling any ongoing image download and clearing the image view.
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        photoImageView.image = nil
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        photoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(photoImageView)
        contentView.addSubview(idLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(sizeLabel)
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = photoImageView.widthAnchor.constraint(equalToConstant: 375)
        widthConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            // Photo Image View Constraints
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            widthConstraint,
            photoImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            photoImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),
            
            // ID Label Constraints
            idLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Author Label Constraints
            authorLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Size Label Constraints
            sizeLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            sizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Ensuring contentView's bottom is anchored by the size label.
            contentView.bottomAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 8)
        ])
    }
    
    //MARK: - Configuration
    
    // Configures the cell with the given photo data and starts loading its image.
    func configure(with photo: Photo, repository: PhotoRepository) {
        idLabel.text = "ID: \(photo.id)"
        idLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        authorLabel.text = "\(photo.author)"
        
        // Calculate the aspect ratio from the photo dimensions.
        let aspectRatio = CGFloat(photo.height) / CGFloat(photo.width)
        
        // Calculate the scaled height for a fixed width of 375.
        let scaledHeight = aspectRatio * 375
        
        // Set the size label with the calculated dimensions.
        sizeLabel.text = "Size: 375x\(Int(scaledHeight))"
        
        // Remove previous aspect ratio constraint if one exists.
        if let constraint = aspectRatioConstraint {
            constraint.isActive = false
        }
        
        aspectRatioConstraint = photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: aspectRatio)
        aspectRatioConstraint?.isActive = true
        
        // Cancel any previously running image download task to avoid incorrect image assignment.
        imageTask?.cancel()
        
        // Begin loading the image using the repository and store the download task.
        imageTask = repository.loadImage(from: photo.downloadUrl) { [weak self] image in
            DispatchQueue.main.async {
                self?.photoImageView.image = image
            }
        }
    }
    
}
