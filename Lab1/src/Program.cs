using System;
using System.Collections.Generic;

namespace Lab1;

public class User
{
    public Guid UserId { get; set; } = Guid.NewGuid();
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? PasswordHash { get; set; }
    public string? AvatarUrl { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public List<Video> Videos { get; set; } = new();
    public List<Comment> Comments { get; set; } = new();
    public List<VideoLike> Likes { get; set; } = new();
    public List<Subscription> Subscriptions { get; set; } = new();
    public List<Subscription> Subscribers { get; set; } = new();
}

public class Video
{
    public Guid VideoId { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }

    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string VideoUrl { get; set; } = string.Empty;
    public string? ThumbnailUrl { get; set; }
    public int DurationSeconds { get; set; }
    public string Visibility { get; set; } = "public";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User? Author { get; set; }
    public List<Comment> Comments { get; set; } = new();
    public List<VideoLike> Likes { get; set; } = new();
}

public class Comment
{
    public Guid CommentId { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public Guid VideoId { get; set; }

    public string Content { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    public User? Author { get; set; }
    public Video? Video { get; set; }
}

public class VideoLike
{
    public Guid LikeId { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public Guid VideoId { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User? User { get; set; }
    public Video? Video { get; set; }
}

public class Subscription
{
    public Guid SubscriptionId { get; set; } = Guid.NewGuid();
    public Guid SubscriberId { get; set; }
    public Guid ChannelId { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User? Subscriber { get; set; }
    public User? Channel { get; set; }
}

public static class Program
{
    public static void Main()
    {
        var author = new User
        {
            Username = "alexander",
            Email = "alexander@example.com",
            PasswordHash = "example_hash"
        };

        var viewer = new User
        {
            Username = "viewer",
            Email = "viewer@example.com"
        };

        var video = new Video
        {
            UserId = author.UserId,
            Author = author,
            Title = "Introduction to VideoHub",
            Description = "Demo video for laboratory work 1.",
            VideoUrl = "https://videohub.local/videos/intro.mp4",
            ThumbnailUrl = "https://videohub.local/images/intro.jpg",
            DurationSeconds = 180,
            Visibility = "public"
        };

        author.Videos.Add(video);

        var comment = new Comment
        {
            UserId = viewer.UserId,
            VideoId = video.VideoId,
            Author = viewer,
            Video = video,
            Content = "Interesting video!"
        };

        viewer.Comments.Add(comment);
        video.Comments.Add(comment);

        var like = new VideoLike
        {
            UserId = viewer.UserId,
            VideoId = video.VideoId,
            User = viewer,
            Video = video
        };

        viewer.Likes.Add(like);
        video.Likes.Add(like);

        var subscription = new Subscription
        {
            SubscriberId = viewer.UserId,
            ChannelId = author.UserId,
            Subscriber = viewer,
            Channel = author
        };

        viewer.Subscriptions.Add(subscription);
        author.Subscribers.Add(subscription);

        Console.WriteLine("=== VideoHub Lab 1 ===");
        Console.WriteLine($"Author: {author.Username}");
        Console.WriteLine($"Video: {video.Title}");
        Console.WriteLine($"Comments: {video.Comments.Count}");
        Console.WriteLine($"Likes: {video.Likes.Count}");
        Console.WriteLine($"Subscribers: {author.Subscribers.Count}");
    }
}
