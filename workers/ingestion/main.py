import os
import json
import logging
from ingest_faq import FAQIngester

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def main():
    logger.info("Starting FAQ ingestion process")

    ingester = FAQIngester()

    faq_file = os.path.join(os.path.dirname(__file__), '../sample-data/ecommerce-faq.json')

    try:
        with open(faq_file, 'r', encoding='utf-8') as f:
            faq_data = json.load(f)

        logger.info(f"Loaded {len(faq_data)} FAQ items")

        success_count = ingester.ingest_documents(faq_data)

        logger.info(f"Successfully ingested {success_count}/{len(faq_data)} documents")

    except Exception as e:
        logger.error(f"Ingestion failed: {str(e)}", exc_info=True)
        raise


if __name__ == "__main__":
    main()