package com.bookstore.util;

/**
 * Utility class for handling book cover images
 */
public class ImageUtil {
    
    private static final String IMAGE_BASE_PATH = "/images/";
    private static final String PLACEHOLDER_BASE = "/placeholder.svg";
    
    /**
     * Get the web-accessible image path for a book cover
     * @param coverImage the cover image filename from database
     * @return web-accessible image path or placeholder
     */
    public static String getImagePath(String coverImage) {
        if (coverImage == null || coverImage.trim().isEmpty() || "null".equals(coverImage)) {
            return null; // Will use placeholder in JSP
        }
        
        // If already a full URL, return as is
        if (coverImage.startsWith("http")) {
            return coverImage;
        }
        
        // If already starts with /images/, return as is
        if (coverImage.startsWith("/images/")) {
            return coverImage;
        }
        
        // If starts with images/, add leading slash
        if (coverImage.startsWith("images/")) {
            return "/" + coverImage;
        }
        
        // Otherwise, prepend the image base path
        return IMAGE_BASE_PATH + coverImage;
    }
    
    /**
     * Get placeholder image URL with specified dimensions
     * @param width image width
     * @param height image height
     * @return placeholder image URL
     */
    public static String getPlaceholderImage(int width, int height) {
        return PLACEHOLDER_BASE + "?height=" + height + "&width=" + width;
    }
    
    /**
     * Get placeholder image URL with specified dimensions and query
     * @param width image width
     * @param height image height  
     * @param query description for the placeholder
     * @return placeholder image URL
     */
    public static String getPlaceholderImage(int width, int height, String query) {
        String url = PLACEHOLDER_BASE + "?height=" + height + "&width=" + width;
        if (query != null && !query.trim().isEmpty()) {
            url += "&query=" + query.replace(" ", "%20");
        }
        return url;
    }
}
