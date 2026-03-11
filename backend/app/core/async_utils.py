# async_utils.py
"""
Async utilities for wrapping blocking Firestore operations.

The google-cloud-firestore SDK (via firebase-admin) is synchronous.
This module provides helpers to run blocking operations in a thread pool
executor without blocking the asyncio event loop.
"""

import asyncio
from typing import TypeVar, Callable, Any
from concurrent.futures import ThreadPoolExecutor
from functools import partial

T = TypeVar('T')

# Shared executor for Firestore operations
# Limited to 10 workers to avoid overwhelming Firestore
_executor = ThreadPoolExecutor(max_workers=10, thread_name_prefix="firestore_")


async def run_sync(func: Callable[..., T], *args: Any, **kwargs: Any) -> T:
    """
    Run a blocking/synchronous function in a thread pool executor.

    This allows calling synchronous Firestore SDK methods without
    blocking the asyncio event loop.

    Args:
        func: The synchronous function to call
        *args: Positional arguments to pass to func
        **kwargs: Keyword arguments to pass to func

    Returns:
        The return value of func

    Example:
        # Instead of blocking the event loop:
        doc = collection.document(doc_id).get()  # BLOCKS!

        # Use run_sync to run in thread pool:
        doc = await run_sync(collection.document(doc_id).get)  # Non-blocking
    """
    loop = asyncio.get_running_loop()

    if kwargs:
        # Use partial to bind kwargs
        func_with_kwargs = partial(func, *args, **kwargs)
        return await loop.run_in_executor(_executor, func_with_kwargs)
    elif args:
        # Use partial to bind args
        func_with_args = partial(func, *args)
        return await loop.run_in_executor(_executor, func_with_args)
    else:
        return await loop.run_in_executor(_executor, func)


def get_executor() -> ThreadPoolExecutor:
    """Get the shared thread pool executor (for testing/cleanup)"""
    return _executor
