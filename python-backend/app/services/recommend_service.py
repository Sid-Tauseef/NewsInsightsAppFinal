# import requests
# import pandas as pd
# import numpy as np
# from sklearn.feature_extraction.text import TfidfVectorizer
# from sklearn.metrics.pairwise import cosine_similarity
# from nltk.corpus import stopwords
# import logging
# import re
# import time

# logger = logging.getLogger(__name__)

# class RecommendationService:
#     def __init__(self):
#         self.NEWSAPI_KEY = "YOUR_API_KEY_FROM_newsapi.org"  # Replace with your actual key
#         self.NEWSAPI_URL = "https://newsapi.org/v2/everything"
#         self.tfidf_vectorizer = TfidfVectorizer(stop_words='english', max_features=5000)
#         self.ENGLISH_STOP_WORDS = set(stopwords.words('english'))

#     def _preprocess_text(self, text):
#         """Preprocess text by removing punctuation, lowercasing, and filtering stop words."""
#         text = re.sub(r"[^\w\s]", "", text.lower())
#         words = [word for word in text.split() if word not in self.ENGLISH_STOP_WORDS]

#     def _sanitize_query(self, text):
#         """Sanitize query for NewsAPI by removing special characters and extracting key terms."""
#         text = text.encode('ascii', errors='ignore').decode('ascii')
#         text = re.sub(r"[^\w\s]", " ", text)
#         words = [word for word in text.split() if word not in self.ENGLISH_STOP_WORDS and len(word) > 2]
#         return " ".join(words[:3]) if words else text.split()[0]

#     def _fetch_news(self, liked_article_text):
#         """Fetch news articles with optimized retry logic"""
#         retries = 3
#         for attempt in range(retries):
#             query = self._sanitize_query(liked_article_text)
#             params = {
#                 "q": query,
#                 "apiKey": self.NEWSAPI_KEY,
#                 "language": "en",
#                 "pageSize": 50,
#                 "sortBy": "relevancy"
#             }
#             try:
#                 response = requests.get(self.NEWSAPI_URL, params=params)
#                 response.raise_for_status()
#                 data = response.json()
#                 articles = data.get("articles", [])
#                 if articles:
#                     return articles
#                 logger.warning(f"No articles found for query: {query}")
#                 return []

#             except requests.exceptions.HTTPError as e:
#                 if e.response.status_code == 429 and attempt < retries - 1:
#                     # Reduced wait time with exponential backoff (0.5s base)
#                     wait_time = (0.25 * (2 ** attempt))  # 0.25s → 0.5s → 1s
#                     logger.warning(f"Rate limit hit (attempt {attempt+1}/{retries}). Waiting {wait_time:.1f}s...")
#                     time.sleep(wait_time)
#                     continue
#                 logger.error(f"API error for query '{query}': {str(e)}")
#                 return []
#             except Exception as e:
#                 logger.error(f"Unexpected error for query '{query}': {str(e)}")
#                 return []
#         return []

#     def _process_article(self, article):
#         """Format raw article data into the required structure."""
#         return {
#             "title": article.get("title", "No Title"),
#             "description": article.get("description", ""),
#             "url": article.get("url", "#"),
#             "urlToImage": article.get("urlToImage", ""),
#             "source": {"name": article.get("source", {}).get("name", "Unknown")},
#             "publishedAt": article.get("publishedAt", ""),
#             "processed_text": ""
#         }

#     def get_recommendations(self, liked_articles):
#         """Generate recommendations with reduced wait times"""
#         try:
#             if not liked_articles:
#                 return []

#             all_recommendations = []
#             logger.debug(f"Received {len(liked_articles)} articles to process: {[art['title'] for art in liked_articles]}")

#             for idx, liked_article in enumerate(liked_articles):
#                 if not isinstance(liked_article, dict) or "title" not in liked_article:
#                     logger.error(f"Invalid article format: {liked_article}")
#                     continue
                
#                 liked_text = liked_article.get("title", "")
#                 if not liked_text:
#                     logger.warning(f"Empty title for article: {liked_article}")
#                     continue

#                 raw_articles = self._fetch_news(liked_text)
#                 if not raw_articles:
#                     continue

#                 articles_df = pd.DataFrame([self._process_article(a) for a in raw_articles])
#                 articles_df["processed_text"] = articles_df["title"].apply(self._preprocess_text)
#                 if articles_df.empty:
#                     logger.warning(f"No processed articles for: '{liked_text}'")
#                     continue

#                 all_texts = [self._preprocess_text(liked_text)] + articles_df["processed_text"].tolist()
#                 tfidf_matrix = self.tfidf_vectorizer.fit_transform(all_texts)
#                 liked_vector = tfidf_matrix[0]
#                 article_vectors = tfidf_matrix[1:]

#                 similarity_scores = cosine_similarity(liked_vector, article_vectors).flatten()
#                 articles_df["score"] = similarity_scores

#                 top_recs = articles_df.sort_values("score", ascending=False).head(5)
#                 recommendations = top_recs.to_dict("records")

#                 for rec in recommendations:
#                     rec.pop("score", None)
#                     rec.pop("processed_text", None)
#                 all_recommendations.extend(recommendations)

#                 # Reduced inter-article delay to 0.5 seconds
#                 if idx < len(liked_articles) - 1:
#                     time.sleep(0.25)  # Half the previous delay

#             return all_recommendations

#         except Exception as e:
#             logger.error(f"Recommendation error: {str(e)}")
#             return []  





import requests
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from nltk.corpus import stopwords
import logging
import re
import time

logger = logging.getLogger(__name__)


class RecommendationService:
    def __init__(self):
        self.NEWSAPI_KEY = "YOUR_API_KEY_FROM_newsapi.org"  # Replace with your actual key
        self.NEWSAPI_URL = "https://newsapi.org/v2/everything"
        self.tfidf_vectorizer = TfidfVectorizer(stop_words='english', max_features=5000)
        self.ENGLISH_STOP_WORDS = set(stopwords.words('english'))

    def _preprocess_text(self, text):
        """Preprocess text by removing punctuation, lowercasing, and filtering stop words."""
        text = re.sub(r"[^\w\s]", "", text.lower())
        words = [word for word in text.split() if word not in self.ENGLISH_STOP_WORDS]
        return " ".join(words)

    def _sanitize_query(self, text):
        """Sanitize query for NewsAPI by removing special characters and extracting key terms."""
        text = text.encode('ascii', errors='ignore').decode('ascii')
        text = re.sub(r"[^\w\s]", " ", text)
        words = [word for word in text.split() if word not in self.ENGLISH_STOP_WORDS and len(word) > 2]
        return " ".join(words[:3]) if words else text.split()[0]

    def _fetch_news(self, liked_article_text):
        """Fetch news articles with optimized retry logic"""
        retries = 3
        for attempt in range(retries):
            query = self._sanitize_query(liked_article_text)
            params = {
                "q": query,
                "apiKey": self.NEWSAPI_KEY,
                "language": "en",
                "pageSize": 50,
                "sortBy": "relevancy"
            }
            try:
                response = requests.get(self.NEWSAPI_URL, params=params)
                response.raise_for_status()
                data = response.json()
                articles = data.get("articles", [])
                if articles:
                    return articles
                logger.warning(f"No articles found for query: {query}")
                return []

            except requests.exceptions.HTTPError as e:
                if e.response.status_code == 429 and attempt < retries - 1:
                    # Reduced wait time with exponential backoff (0.5s base)
                    wait_time = (0.25 * (2 ** attempt))  # 0.25s → 0.5s → 1s
                    logger.warning(f"Rate limit hit (attempt {attempt+1}/{retries}). Waiting {wait_time:.1f}s...")
                    time.sleep(wait_time)
                    continue
                logger.error(f"API error for query '{query}': {str(e)}")
                return []
            except Exception as e:
                logger.error(f"Unexpected error for query '{query}': {str(e)}")
                return []
        return []

    def _process_article(self, article):
        """Format raw article data into the required structure."""
        return {
            "title": article.get("title", "No Title"),
            "description": article.get("description", ""),
            "url": article.get("url", "#"),
            "urlToImage": article.get("urlToImage", ""),
            "source": {"name": article.get("source", {}).get("name", "Unknown")},
            "publishedAt": article.get("publishedAt", ""),
            "processed_text": ""
        }

    def get_recommendations(self, liked_articles):
        """Generate recommendations with reduced wait times"""
        try:
            if not liked_articles:
                return []

            all_recommendations = []
            logger.debug(f"Received {len(liked_articles)} articles to process: {[art['title'] for art in liked_articles]}")

            for idx, liked_article in enumerate(liked_articles):
                if not isinstance(liked_article, dict) or "title" not in liked_article:
                    logger.error(f"Invalid article format: {liked_article}")
                    continue
                
                liked_text = liked_article.get("title", "")
                if not liked_text:
                    logger.warning(f"Empty title for article: {liked_article}")
                    continue

                raw_articles = self._fetch_news(liked_text)
                if not raw_articles:
                    continue

                articles_df = pd.DataFrame([self._process_article(a) for a in raw_articles])
                articles_df["processed_text"] = articles_df["title"].apply(self._preprocess_text)
                if articles_df.empty:
                    logger.warning(f"No processed articles for: '{liked_text}'")
                    continue

                all_texts = [self._preprocess_text(liked_text)] + articles_df["processed_text"].tolist()
                tfidf_matrix = self.tfidf_vectorizer.fit_transform(all_texts)
                liked_vector = tfidf_matrix[0]
                article_vectors = tfidf_matrix[1:]

                similarity_scores = cosine_similarity(liked_vector, article_vectors).flatten()
                articles_df["score"] = similarity_scores

                top_recs = articles_df.sort_values("score", ascending=False).head(5)
                recommendations = top_recs.to_dict("records")

                for rec in recommendations:
                    rec.pop("score", None)
                    rec.pop("processed_text", None)
                all_recommendations.extend(recommendations)

                # Reduced inter-article delay to 0.5 seconds
                if idx < len(liked_articles) - 1:
                    time.sleep(0.25)  # Half the previous delay

            return all_recommendations

        except Exception as e:
            logger.error(f"Recommendation error: {str(e)}")
            return []

















# import requests
# import pandas as pd
# import numpy as np
# from sklearn.feature_extraction.text import TfidfVectorizer
# from sklearn.metrics.pairwise import cosine_similarity
# from nltk.corpus import stopwords
# import logging
# import re
# import time

# logger = logging.getLogger(__name__)

# class RecommendationService:
#     def __init__(self):
#         self.NEWSAPI_KEY = "YOUR_API_KEY_FROM_newsapi.org"  # Replace with your actual key
#         self.NEWSAPI_URL = "https://newsapi.org/v2/everything"
#         self.tfidf_vectorizer = TfidfVectorizer(stop_words='english', max_features=5000)
#         self.ENGLISH_STOP_WORDS = set(stopwords.words('english'))

#     def _preprocess_text(self, text):
#         """Preprocess text by removing punctuation, lowercasing, and filtering stop words."""
#         text = re.sub(r"[^\w\s]", "", text.lower())
#         words = [word for word in text.split() if word not in self.ENGLISH_STOP_WORDS]
#         return " ".join(words)

#     def _sanitize_query(self, text):
#         """Sanitize query for NewsAPI by removing special characters and extracting key terms."""
#         text = text.encode('ascii', errors='ignore').decode('ascii')
#         text = re.sub(r"[^\w\s]", " ", text)
#         words = [word for word in text.split() if word not in self.ENGLISH_STOP_WORDS and len(word) > 2]
#         return " ".join(words[:3]) if words else text.split()[0]

#     def _fetch_news(self, liked_article_text):
#         """Fetch news articles with optimized retry logic"""
#         retries = 3
#         for attempt in range(retries):
#             query = self._sanitize_query(liked_article_text)
#             params = {
#                 "q": query,
#                 "apiKey": self.NEWSAPI_KEY,
#                 "language": "en",
#                 "pageSize": 50,
#                 "sortBy": "relevancy"
#             }
#             try:
#                 response = requests.get(self.NEWSAPI_URL, params=params)
#                 response.raise_for_status()
#                 data = response.json()
#                 articles = data.get("articles", [])
#                 if articles:
#                     return articles
#                 logger.warning(f"No articles found for query: {query}")
#                 return []

#             except requests.exceptions.HTTPError as e:
#                 if e.response.status_code == 429 and attempt < retries - 1:
#                     wait_time = (0.25 * (2 ** attempt))
#                     logger.warning(f"Rate limit hit (attempt {attempt+1}/{retries}). Waiting {wait_time:.1f}s...")
#                     time.sleep(wait_time)
#                     continue
#                 logger.error(f"API error for query '{query}': {str(e)}")
#                 return []
#             except Exception as e:
#                 logger.error(f"Unexpected error for query '{query}': {str(e)}")
#                 return []
#         return []

#     def _process_article(self, article):
#         """Format raw article data into the required structure."""
#         return {
#             "title": article.get("title", "No Title"),
#             "description": article.get("description", ""),
#             "url": article.get("url", "#"),
#             "urlToImage": article.get("urlToImage", ""),
#             "source": {"name": article.get("source", {}).get("name", "Unknown")},
#             "publishedAt": article.get("publishedAt", ""),
#             "processed_text": ""
#         }

#     def get_recommendations(self, liked_articles):
#         """Generate recommendations with evaluation metrics"""
#         # Initialize metrics containers
#         metrics = {
#             'all_scores': [],
#             'all_processed_texts': [],
#             'all_sources': [],
#             'total_articles_fetched': 0
#         }
#         all_recommendations = []
        
#         try:
#             if not liked_articles:
#                 logger.info("No liked articles provided for recommendations")
#                 return []

#             logger.info(f"Processing {len(liked_articles)} liked articles")

#             for idx, liked_article in enumerate(liked_articles):
#                 if not isinstance(liked_article, dict) or "title" not in liked_article:
#                     logger.error(f"Invalid article format: {liked_article}")
#                     continue
                
#                 liked_text = liked_article.get("title", "")
#                 if not liked_text:
#                     logger.warning(f"Empty title for article: {liked_article}")
#                     continue

#                 raw_articles = self._fetch_news(liked_text)
#                 if not raw_articles:
#                     continue

#                 metrics['total_articles_fetched'] += len(raw_articles)
#                 articles_df = pd.DataFrame([self._process_article(a) for a in raw_articles])
#                 articles_df["processed_text"] = articles_df["title"].apply(self._preprocess_text)
                
#                 if articles_df.empty:
#                     logger.warning(f"No processed articles for: '{liked_text}'")
#                     continue

#                 # Calculate similarity scores
#                 all_texts = [self._preprocess_text(liked_text)] + articles_df["processed_text"].tolist()
#                 tfidf_matrix = self.tfidf_vectorizer.fit_transform(all_texts)
#                 similarity_scores = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:]).flatten()
#                 articles_df["score"] = similarity_scores

#                 # Store metrics
#                 metrics['all_scores'].extend(similarity_scores)
#                 metrics['all_processed_texts'].extend(articles_df["processed_text"].tolist())
#                 metrics['all_sources'].extend(articles_df["source"].apply(lambda x: x['name']).tolist())

#                 # Get top recommendations
#                 top_recs = articles_df.sort_values("score", ascending=False).head(5)
#                 for rec in top_recs.to_dict("records"):
#                     rec.pop("score", None)
#                     rec.pop("processed_text", None)
#                     all_recommendations.append(rec)

#                 if idx < len(liked_articles) - 1:
#                     time.sleep(0.25)

#         except Exception as e:
#             logger.error(f"Recommendation processing error: {str(e)}", exc_info=True)
#             # Still return whatever recommendations we've gathered so far
#             return all_recommendations

#         finally:
#             # Always log metrics, even if there was an error
#             self._log_metrics(metrics, len(all_recommendations), len(liked_articles))

#         return all_recommendations

#     def _log_metrics(self, metrics, total_recommendations, input_articles_count):
#         """Calculate and log evaluation metrics"""
#         if not metrics['all_scores']:
#             logger.info("No recommendation metrics available (no valid articles processed)")
#             return

#         logger.info("\n=== Recommendation Metrics ===")
        
#         # Basic stats
#         avg_score = np.mean(metrics['all_scores'])
#         logger.info(f"Average Similarity Score: {avg_score:.4f}")
#         logger.info(f"Total Recommendations Generated: {total_recommendations}")
#         logger.info(f"Total Articles Fetched: {metrics['total_articles_fetched']}")
        
#         # Diversity calculation
#         try:
#             if len(metrics['all_processed_texts']) >= 2:
#                 diversity_vectorizer = TfidfVectorizer(stop_words='english', max_features=2000)
#                 diversity_matrix = diversity_vectorizer.fit_transform(metrics['all_processed_texts'])
#                 pairwise_sim = cosine_similarity(diversity_matrix)
#                 np.fill_diagonal(pairwise_sim, 0)
#                 diversity_score = pairwise_sim.sum() / (len(pairwise_sim) * (len(pairwise_sim)-1))
#                 logger.info(f"Recommendation Diversity: {1 - diversity_score:.4f} (higher is better)")
#             else:
#                 logger.info("Recommendation Diversity: Not enough articles to calculate")
#         except Exception as e:
#             logger.error(f"Could not calculate diversity: {str(e)}")

#         # Source coverage
#         unique_sources = len(set(metrics['all_sources']))
#         coverage = unique_sources / len(metrics['all_sources']) if metrics['all_sources'] else 0
#         logger.info(f"Source Coverage: {coverage:.2%} ({unique_sources} unique sources)")

#         # Score distribution
#         logger.info("Score Distribution:")
#         logger.info(f"- Max: {np.max(metrics['all_scores']):.4f}")
#         logger.info(f"- 75th percentile: {np.percentile(metrics['all_scores'], 75):.4f}")
#         logger.info(f"- Median: {np.median(metrics['all_scores']):.4f}")
#         logger.info(f"- 25th percentile: {np.percentile(metrics['all_scores'], 25):.4f}")
#         logger.info(f"- Min: {np.min(metrics['all_scores']):.4f}")

#         # Efficiency metrics
#         if input_articles_count > 0:
#             logger.info(f"Recommendations per Input Article: {total_recommendations/input_articles_count:.1f}")
#             logger.info(f"Articles Fetched per Input Article: {metrics['total_articles_fetched']/input_articles_count:.1f}")

#         logger.info("="*30)
