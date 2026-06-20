import os
import re
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api.formatters import TextFormatter

# Paste your full YouTube URLs or short links here
YOUTUBE_URLS = [
    "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "https://youtu.be/pxiP-HJLCx0",
    "https://www.youtube.com/shorts/abc123XYZ"
]

TRANSCRIPTS_DIR = "docs/youtube-transcripts"

def extract_video_id(url):
    """
    Extracts the 11-character video ID from various YouTube URL formats.
    Matches standard watch URLs, short links (youtu.be), embeds, and shorts.
    """
    pattern = r'(?:v=|\/embed\/|\/1\/|\/v\/|https:\/\/youtu\.be\/|\/shorts\/)([a-zA-Z0-9_-]{11})'
    match = re.search(pattern, url)
    if match:
        return match.group(1)
    return None

def setup_directory():
    if not os.path.exists(TRANSCRIPTS_DIR):
        os.makedirs(TRANSCRIPTS_DIR)
        print(f"Created directory: {TRANSCRIPTS_DIR}")

def fetch_transcripts():
    setup_directory()
    formatter = TextFormatter()
    
    for url in YOUTUBE_URLS:
        url = url.strip()
        if not url:
            continue
            
        video_id = extract_video_id(url)
        
        if not video_id:
            print(f"Could not parse a valid YouTube Video ID from URL: {url}")
            continue
            
        print(f"Fetching transcript for video ID: {video_id}...")
        try:
            # Retrieve the transcript data
            transcript = YouTubeTranscriptApi.get_transcript(video_id)
            
            # Format it into clean plain text without timestamps
            formatted_text = formatter.format_transcript(transcript)
            
            # Save to a text file
            filepath = os.path.join(TRANSCRIPTS_DIR, f"{video_id}.txt")
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(f"Source URL: {url}\n")
                f.write(f"Video ID: {video_id}\n\n")
                f.write(formatted_text)
                
            print(f"Successfully saved to {filepath}")
            
        except Exception as e:
            print(f"Error fetching transcript for {video_id}: {e}")

if __name__ == "__main__":
    fetch_transcripts()