require "rspec/autorun"
require 'pry'

    class LiveOrderAPIClient
        def self.get_next_orders(start=0, length=10, **filters)
            """
                Fetch the next set of orders from the queue.
                Optionally you can filter for specific types of orders.
            """
    
            # Mocked out in the specs
        end
    end
    
    class OrderCollection
        include Enumerable
    
        def initialize(offset=0, limit=-1, page_size=10, **filters)
            @offset = offset
            @limit = limit
            @page_size = page_size
            @filters = filters
        end
    
        def each
            records_fetched = 0
            records_total = -1
            records_filtered = 0
            data = []
            index = 0

            loop do

                if (index += 1) < data.length
                    yield data[index]
                else
                    # TODO: Loop End Condition
                    # binding.pry    
                    break if (records_fetched + records_filtered == records_total) || records_fetched == @limit
                    # binding.pry
                    index = 0
                    result = LiveOrderAPIClient.get_next_orders records_fetched + @offset, @page_size, **@filters
                    data = result[:data]
                    records_fetched += result[:data].length
                    records_total = result[:records_total]
                    records_filtered = result[:records_filtered]
                    yield data[index]
                end
            end
        end
    end
    
    describe OrderCollection do
        it "should return 100 orders" do
            allow(LiveOrderAPIClient).to receive(:get_next_orders) {|start, length| 
                {
                    data: (1..100).to_a[start,length],
                    records_total: 100,
                    records_filtered: 0
                }
            }
    
            items = OrderCollection.new()
            expect(items.to_a).to eq((1..100).to_a)
        end
    
        it "should return 50 orders" do
            allow(LiveOrderAPIClient).to receive(:get_next_orders) {|start, length| 
                {
                    data: (1..50).to_a[start,length],
                    records_total: 100,
                    records_filtered: 50
                }
            }
    
            items = OrderCollection.new(less_than_or_equal: 50)
            expect(items.to_a).to eq((1..50).to_a)
        end
    end

    
    # 2. Expand the test suite to catch and fix more bugs.

    # 3. Remember get_next_orders() is hitting a highly stressed live-order API server. Describe some consistency and concurrency issues faced in this scenario. 

    # 4. Add tests to catch such scenarios. Fix the code to handle these scenarios, where possible.
    
    # Consistency and Concurrency problems

    # Edge cases

    # Two or more people consuming next orders:
    # Problem: if there is another store and you proceed to fetch orders we might want to push the consumed orders after they are processed in our end.