//
//  PhotosModel.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import UIKit

typealias PhotosModel = [Photo]

struct Photo: Codable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let promotedAt: String?
    let width: CGFloat
    let height: CGFloat
    let color: String
    let blurHash: String
    let description: String?
    let altDescription: String?
    let urls: Urls
    let links: Links
    let categories: [String]?
    let likes: Int
    let likedByUser: Bool
    let currentUserCollections: [CurrentUserCollections]?
    let sponsorship: String?
    let user: User
    let exif: Exif
    let location: Location
    let views: Int
    let downloads: Int

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case promotedAt = "promoted_at"
        case width, height, color
        case blurHash = "blur_hash"
        case description = "description"
        case altDescription = "alt_description"
        case urls
        case links
        case categories
        case likes
        case likedByUser = "liked_by_user"
        case currentUserCollections = "current_user_collections"
        case sponsorship, user, exif, location
        case views, downloads
    }
    
    // MARK: - Urls
    struct Urls: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    
    // MARK: - Links
    struct Links: Codable {
        let linksSelf: String
        let html: String
        let download: String
        let downloadLocation: String

        enum CodingKeys: String, CodingKey {
            case linksSelf = "self"
            case html, download
            case downloadLocation = "download_location"
        }
    }
    
    // MARK: - CurrentUserCollections
    struct CurrentUserCollections: Codable {
        let id: Int
        let title: String
        let publishedAt: String?
        let lastCollectedAt: String?
        let updatedAt: String?
        let coverPhoto: String?
        let user: String?

        enum CodingKeys: String, CodingKey {
            case id, title
            case publishedAt = "published_at"
            case lastCollectedAt = "last_collected_at"
            case updatedAt = "updated_at"
            case coverPhoto = "cover_photo"
            case user
        }
    }
    
    // MARK: - User
    struct User: Codable {
        let id: String
        let updatedAt: String?
        let username: String
        let name: String
        let firstName: String
        let lastName: String?
        let twitterUsername: String?
        let portfolioURL: String?
        let bio: String?
        let location: String?
        let links: UserLinks
        let profileImage: ProfileImage?
        let instagramUsername: String?
        let totalCollections: Int
        let totalLikes: Int
        let totalPhotos: Int
        let acceptedTos: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case updatedAt = "updated_at"
            case username, name
            case firstName = "first_name"
            case lastName = "last_name"
            case twitterUsername = "twitter_username"
            case portfolioURL = "portfolio_url"
            case bio, location, links
            case profileImage = "profile_image"
            case instagramUsername = "instagram_username"
            case totalCollections = "total_collections"
            case totalLikes = "total_likes"
            case totalPhotos = "total_photos"
            case acceptedTos = "accepted_tos"
        }
        
        // MARK: - UserLinks
        struct UserLinks: Codable {
            let linksSelf: String
            let html: String
            let photos: String
            let likes: String
            let portfolio: String
            let following: String
            let followers: String

            enum CodingKeys: String, CodingKey {
                case linksSelf = "self"
                case html, photos, likes, portfolio, following, followers
            }
        }
        
        // MARK: - ProfileImage
        struct ProfileImage: Codable {
            let small: String?
            let medium: String?
            let large: String?
        }
    }
    
    // MARK: - Exif
    struct Exif: Codable {
        let make: String?
        let model: String?
        let exposureTime: String?
        let aperture: String?
        let focalLength: String?
        let iso: Int?

        enum CodingKeys: String, CodingKey {
            case make, model
            case exposureTime = "exposure_time"
            case aperture
            case focalLength = "focal_length"
            case iso
        }
    }
    
    // MARK: - Location
    struct Location: Codable {
        let title: String?
        let name: String?
        let city: String?
        let country: String?
        let position: Position?
        
        // MARK: - Position
        struct Position: Codable {
            let latitude: CGFloat?
            let longitude: CGFloat?
        }
    }
}
