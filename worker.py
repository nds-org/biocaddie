#!/usr/bin/env python

import logging
import time
import rediswq
import sys
import os
import subprocess

host = os.getenv("REDIS_SERVICE_HOST")
queue = os.getenv("REDIS_SERVICE_QUEUE")

# Ensure that our output folder exists
output_dir='/output/' + queue.replace('-', '/')
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Set up a basic file logger
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging

q = rediswq.RedisWQ(name=queue, host=host)
logger.info("Worker started with sessionID: {0}".format(q.sessionID()))
logger.debug("Initial state: empty={0}".format(str(q.empty())))

# Timeout for worker pods in seconds
timeout=600
start_time = time.time()
next_timeout = start_time + timeout

while not q.empty() and time.time() < next_timeout:
  item = q.lease(lease_secs=600, block=True, timeout=2) 
  if item is not None:
    # Read a work item (a bash command) from the queue
    command = item.decode("utf=8")
    logger.info("Running command: {0}".format(command))

    try:
        # Execute the command given by the queue item
        output = subprocess.check_output(['bash', '-c', command], shell=False) 
        # Mark the item as complete in the queue
        q.complete(item)

	next_timeout = time.time() + timeout
    except CalledProcessError as ex:
        logger.error("ERROR: {0} - {1}".format(ex.returnCode, ex.output))

  else:
    logger.debug("Waiting for work")
    
logger.debug("Queue is empty after timeout, exiting")

# Calculate elapsed run time
elapsed_time=time.time() - start_time
logger.info("Worker finished in {0:.3f} seconds".format(elapsed_time))
