from database import get_connection
from etl.load_raw import initialize_raw_layer, load_raw_layer
from etl.load_stg import initialize_stg_layer, load_stg_layer
from etl.load_final import initialize_final_layer, load_final_layer
from etl.load_incremental import (
    initialize_batch_tracker,
    start_batch,
    end_batch,
    load_incremental_raw,
    load_incremental_stg,
    load_incremental_final
)

if __name__ == "__main__":

    # # # # # # # # # # # # # # # #
    # # DATABASE CONNECTION # # # #
    # # # # # # # # # # # # # # # #
    conn = get_connection()
    print("Database Connected Successfully")
    cur = conn.cursor()

    # # # # # # # # # # # # # # # #
    # # # # RAW LAYER # # # # # # #
    # # # # # # # # # # # # # # # #
    # initialize_raw_layer(cur)
    # load_raw_layer(cur)
    # conn.commit()
    # print("RAW layer loaded successfully")

    # # # # # # # # # # # # # # # #
    # # # STAGING LAYER # # # # # #
    # # # # # # # # # # # # # # # #
    # initialize_stg_layer(cur)
    # load_stg_layer(cur)
    # conn.commit()
    # print("STAGING layer loaded successfully")

    # # # # # # # # # # # # # # # #
    # # # WAREHOUSE LAYER # # # # #
    # # # # # # # # # # # # # # # #
    # initialize_final_layer(cur)
    # load_final_layer(cur)
    # conn.commit()
    # print("WAREHOUSE layer loaded successfully")

    # # # # # # # # # # # # # # # #
    # # # INCREMENTAL LOAD # # # #
    # # # # # # # # # # # # # # # #
    initialize_batch_tracker(cur)
    conn.commit()

    batch_id = start_batch(cur)
    conn.commit()
    print(f"Batch {batch_id} started!")

    try:
        # # LOAD NEW CSV INTO RAW
        load_incremental_raw(
            cur,
            "data/new/incremental_2018.csv"
        )

        # # CLEAN AND TRANSFORM INTO STAGING
        load_incremental_stg(cur)

        # # LOAD INTO STAR SCHEMA
        load_incremental_final(cur)

        conn.commit()

        # # MARK BATCH AS SUCCESS
        end_batch(cur, batch_id, "success")
        conn.commit()
        print(f"Batch {batch_id} completed successfully!")

    except Exception as e:
        # # MARK BATCH AS FAILED
        end_batch(cur, batch_id, "failed", str(e))
        conn.commit()
        print(f"Batch {batch_id} failed: {e}")

    # # # # # # # # # # # # # # # #
    # # # CLOSE CONNECTION # # # #
    # # # # # # # # # # # # # # # #
    conn.close()