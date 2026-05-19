import logging
from typing import Optional, Dict, Any
from datetime import datetime, timedelta
import random

logger = logging.getLogger(__name__)


class OrderService:
    """
    Mock order service for demo purposes.
    In production, replace with OMS/ERP integration.
    """

    MOCK_ORDERS = {
        "ORD-123456": {
            "order_number": "ORD-123456",
            "status": "In Transit",
            "items": ["Blue Running Shoes", "Sports Water Bottle"],
            "total": "$89.99",
            "order_date": "2024-01-10",
            "estimated_delivery": "2024-01-18",
            "tracking_number": "1Z999AA10123456784",
            "carrier": "UPS"
        },
        "ORD-789012": {
            "order_number": "ORD-789012",
            "status": "Delivered",
            "items": ["Wireless Headphones"],
            "total": "$129.99",
            "order_date": "2024-01-05",
            "delivered_date": "2024-01-12",
            "tracking_number": "1Z999AA10123456789",
            "carrier": "FedEx"
        }
    }

    async def get_order_status(self, order_number: str) -> Optional[Dict[str, Any]]:
        try:
            order_number = order_number.upper()
            if not order_number.startswith("ORD-"):
                order_number = f"ORD-{order_number}"

            if order_number in self.MOCK_ORDERS:
                logger.info(f"Found order: {order_number}")
                return self.MOCK_ORDERS[order_number]

            logger.info(f"Generating mock order for: {order_number}")
            return self._generate_mock_order(order_number)

        except Exception as e:
            logger.error(f"Error getting order status: {str(e)}")
            return None

    def _generate_mock_order(self, order_number: str) -> Dict[str, Any]:
        statuses = ["Processing", "In Transit", "Out for Delivery", "Delivered"]
        status = random.choice(statuses)

        order_date = datetime.now() - timedelta(days=random.randint(1, 14))
        delivery_date = order_date + timedelta(days=random.randint(5, 10))

        result = {
            "order_number": order_number,
            "status": status,
            "items": ["Product Item"],
            "total": f"${random.randint(20, 200)}.99",
            "order_date": order_date.strftime("%Y-%m-%d"),
            "estimated_delivery": delivery_date.strftime("%Y-%m-%d"),
            "tracking_number": f"1Z999AA{random.randint(10000000, 99999999)}",
            "carrier": random.choice(["UPS", "FedEx", "DHL"])
        }

        if status == "Delivered":
            result["delivered_date"] = delivery_date.strftime("%Y-%m-%d")

        return result